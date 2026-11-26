using Npgsql;

var builder = WebApplication.CreateBuilder(args);

var connString = builder.Configuration.GetConnectionString("Default")
    ?? throw new InvalidOperationException("Thiếu ConnectionStrings:Default (dùng dotnet user-secrets).");

builder.Services.AddSingleton(NpgsqlDataSource.Create(connString));
builder.Services.AddProblemDetails();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

// GET /api/v1/courses/{courseId}/registrations
app.MapGet("/api/v1/courses/{courseId:int}/registrations", async (int courseId, NpgsqlDataSource db) =>
{
    await using var conn = await db.OpenConnectionAsync();

    // Kiểm tra khoá học tồn tại -> 404
    await using (var check = new NpgsqlCommand("SELECT 1 FROM courses WHERE id = @courseId", conn))
    {
        check.Parameters.AddWithValue("courseId", courseId);
        if (await check.ExecuteScalarAsync() is null)
        {
            return Results.Problem(
                type: "https://eduhub.example.com/problems/course-not-found",
                title: "Course not found",
                statusCode: StatusCodes.Status404NotFound,
                detail: $"Không tìm thấy khoá học có id {courseId}.");
        }
    }

    // Truy vấn có tham số, không nối chuỗi vào câu SQL
    const string sql = """
        SELECT id, member_id, course_id, status
        FROM registrations
        WHERE course_id = @courseId
        ORDER BY id
        """;

    var danhSach = new List<RegistrationDto>();
    await using var cmd = new NpgsqlCommand(sql, conn);
    cmd.Parameters.AddWithValue("courseId", courseId);

    await using var reader = await cmd.ExecuteReaderAsync();
    while (await reader.ReadAsync())
    {
        danhSach.Add(new RegistrationDto(
            reader.GetInt32(0),
            reader.GetInt32(1),
            reader.GetInt32(2),
            reader.GetString(3)));
    }

    return Results.Ok(danhSach);
});

// POST /api/v1/courses/{courseId}/registrations
app.MapPost("/api/v1/courses/{courseId:int}/registrations",
    async (int courseId, CreateRegistrationRequest? body, NpgsqlDataSource db) =>
{
    if (body?.MemberId is null)
    {
        return Results.Problem(
            type: "https://eduhub.example.com/problems/invalid-request",
            title: "Invalid request",
            statusCode: StatusCodes.Status400BadRequest,
            detail: "Thiếu trường memberId trong body.");
    }

    var memberId = body.MemberId.Value;
    await using var conn = await db.OpenConnectionAsync();

    // Kiểm tra khoá học và thành viên tồn tại -> 404
    foreach (var (table, id, name) in new[] { ("courses", courseId, "khoá học"), ("members", memberId, "thành viên") })
    {
        await using var check = new NpgsqlCommand($"SELECT 1 FROM {table} WHERE id = @id", conn);
        check.Parameters.AddWithValue("id", id);
        if (await check.ExecuteScalarAsync() is null)
        {
            return Results.Problem(
                type: $"https://eduhub.example.com/problems/{table}-not-found",
                title: "Resource not found",
                statusCode: StatusCodes.Status404NotFound,
                detail: $"Không tìm thấy {name} có id {id}.");
        }
    }

    const string sql = """
        INSERT INTO registrations (member_id, course_id, status)
        VALUES (@memberId, @courseId, 'pending')
        RETURNING id, status
        """;

    try
    {
        await using var cmd = new NpgsqlCommand(sql, conn);
        cmd.Parameters.AddWithValue("memberId", memberId);
        cmd.Parameters.AddWithValue("courseId", courseId);

        await using var reader = await cmd.ExecuteReaderAsync();
        await reader.ReadAsync();
        var created = new RegistrationDto(reader.GetInt32(0), memberId, courseId, reader.GetString(1));

        return Results.Created($"/api/v1/registrations/{created.Id}", created);
    }
    catch (PostgresException ex) when (ex.SqlState == PostgresErrorCodes.UniqueViolation)
    {
        // Vi phạm UNIQUE (member_id, course_id) -> 409
        return Results.Problem(
            type: "https://eduhub.example.com/problems/duplicate-registration",
            title: "Duplicate registration",
            statusCode: StatusCodes.Status409Conflict,
            detail: $"Thành viên có id {memberId} đã đăng ký khoá học có id {courseId}.",
            instance: $"/api/v1/courses/{courseId}/registrations");
    }
});

app.Lifetime.ApplicationStarted.Register(() =>
{
    foreach (var url in app.Urls)
        Console.WriteLine($"Swagger UI: {url}/swagger");
});

app.Run();

record RegistrationDto(int Id, int MemberId, int CourseId, string Status);
record CreateRegistrationRequest(int? MemberId);