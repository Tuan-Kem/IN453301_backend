# Thiết kế REST API – EduHub mini

Quy ước chung:

- Base URL: `/api/v1`
- URI dùng **danh từ số nhiều**, không chứa động từ.
- Dữ liệu trao đổi dạng JSON. Lỗi trả về theo **Problem Details (RFC 9457)** với `Content-Type: application/problem+json`.

## 2.1. Bảng thiết kế các chức năng của `registrations`

| STT | Chức năng | Method | URI | Mã thành công | Các mã lỗi có thể gặp |
|---|---|---|---|---|---|
| 1 | Xem danh sách đăng ký của một khoá học | `GET` | `/api/v1/courses/{courseId}/registrations` | `200 OK` | `400` tham số lọc/phân trang không hợp lệ; `404` khoá học không tồn tại |
| 2 | Tạo đăng ký | `POST` | `/api/v1/courses/{courseId}/registrations` | `201 Created` (kèm header `Location`) | `400` body sai định dạng hoặc thiếu `memberId`; `404` khoá học hoặc thành viên không tồn tại; `409` thành viên đã đăng ký khoá học này; `422` vi phạm nghiệp vụ (vd: khoá học đã đủ chỗ) |
| 3 | Xác nhận đăng ký | `PATCH` | `/api/v1/registrations/{registrationId}` <br> Body: `{ "status": "confirmed" }` | `200 OK` | `400` trạng thái không hợp lệ; `404` đăng ký không tồn tại; `409` đăng ký đã bị huỷ hoặc đã xác nhận trước đó |
| 4 | Huỷ đăng ký | `DELETE` | `/api/v1/registrations/{registrationId}` | `204 No Content` | `404` đăng ký không tồn tại; `409` đăng ký không ở trạng thái cho phép huỷ |

Giải thích lựa chọn thiết kế:

- Danh sách và tạo đăng ký nằm **dưới khoá học** (`/courses/{courseId}/registrations`) vì đăng ký thuộc về một khoá học cụ thể (quan hệ cha – con).
- Xác nhận và huỷ thao tác trên **một đăng ký đã có id**, nên dùng `/registrations/{registrationId}`. Hành động "xác nhận" được biểu diễn bằng việc cập nhật trường `status` qua `PATCH`, không dùng động từ như `/confirm` trong URI.
- `POST` không idempotent nên trả `201` và header `Location: /api/v1/registrations/{id}`. `DELETE` thành công không có nội dung nên trả `204`.

## 2.2. JSON mẫu cho chức năng tạo đăng ký

### Request

```http
POST /api/v1/courses/2/registrations
Content-Type: application/json

{
  "memberId": 3
}
```

### Response thành công

```http
201 Created
Location: /api/v1/registrations/7
Content-Type: application/json

{
  "id": 7,
  "memberId": 3,
  "courseId": 2,
  "status": "pending"
}
```

### Response lỗi – trùng đăng ký (Problem Details, RFC 9457)

Tình huống: thành viên có `id = 3` đã đăng ký khoá học `id = 2` trước đó.

```http
409 Conflict
Content-Type: application/problem+json

{
  "type": "https://eduhub.example.com/problems/duplicate-registration",
  "title": "Duplicate registration",
  "status": 409,
  "detail": "Thành viên có id 3 đã đăng ký khoá học có id 2.",
  "instance": "/api/v1/courses/2/registrations"
}
```

Ý nghĩa các trường Problem Details:

| Trường | Ý nghĩa |
|---|---|
| `type` | URI định danh loại lỗi (không bắt buộc phải truy cập được) |
| `title` | Tóm tắt ngắn gọn, cố định cho mỗi loại lỗi |
| `status` | Mã HTTP, trùng với mã trả về |
| `detail` | Mô tả cụ thể cho lần lỗi này |
| `instance` | URI của request gây ra lỗi |