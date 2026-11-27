# Kiểm thử API – EduHub mini

API chạy tại `http://localhost:5000` (`dotnet run --urls http://localhost:5000`).
Các lệnh dưới đây chạy trên Git Bash. Nếu dùng PowerShell, hãy dùng `curl.exe` và thoát dấu nháy kép trong JSON.

## 1. Xem danh sách đăng ký của một khoá học

```bash
curl -i http://localhost:5000/api/v1/courses/2/registrations
```

- Trạng thái dự kiến: `200 OK` (trả về mảng JSON các đăng ký).
- Khoá học không tồn tại (ví dụ `/courses/999/registrations`): `404 Not Found`.

## 2. Tạo đăng ký

```bash
curl -i -X POST http://localhost:5000/api/v1/courses/2/registrations \
  -H "Content-Type: application/json" \
  -d '{"memberId": 3}'
```

- Trạng thái dự kiến: `201 Created` (kèm header `Location`, `status` là `pending`).
- Gửi lại đúng lệnh trên lần nữa: `409 Conflict` (trùng đăng ký, `application/problem+json`).
- Thiếu `memberId`: `400 Bad Request`.
- `memberId` không tồn tại: `404 Not Found`.

## 3. Xác nhận đăng ký

```bash
curl -i -X PATCH http://localhost:5000/api/v1/registrations/7 \
  -H "Content-Type: application/json" \
  -d '{"status": "confirmed"}'
```

- Trạng thái dự kiến: `200 OK`.
- Đăng ký không tồn tại: `404 Not Found`.
- Đăng ký đã huỷ hoặc đã xác nhận trước đó: `409 Conflict`.

## 4. Huỷ đăng ký

```bash
curl -i -X DELETE http://localhost:5000/api/v1/registrations/7
```

- Trạng thái dự kiến: `204 No Content`.
- Đăng ký không tồn tại: `404 Not Found`.

> Lệnh 3 và 4 thuộc phần thiết kế (mục 2.1). Phần cài đặt (mục 3.2) làm hai endpoint: lệnh 1 và lệnh 2.