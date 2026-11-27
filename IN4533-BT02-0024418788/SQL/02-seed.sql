INSERT INTO members (full_name, email) VALUES
    ('Nguyễn An', 'an@dthu.edu.vn'),
    ('Trần Bình', 'binh@dthu.edu.vn'),
    ('Lê Chi', 'chi@dthu.edu.vn'),
    ('Phạm Dũng', 'dung@dthu.edu.vn');

INSERT INTO courses (title, capacity) VALUES
    ('Lập trình Web', 2),
    ('Cơ sở dữ liệu', 40),
    ('Lập trình Back End', 30);

INSERT INTO registrations (member_id, course_id, status) VALUES
    (1, 1, 'confirmed'),
    (1, 2, 'pending'),
    (2, 1, 'pending'),
    (2, 3, 'confirmed'),
    (4, 1, 'confirmed'),
    (4, 2, 'cancelled');