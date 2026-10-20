# Korean Game Dictionary

## Chạy trong VS Code
Mở thư mục bằng VS Code, mở `index.html` bằng extension Live Server.

## Kết nối Supabase
1. Trong Supabase SQL Editor, chạy **supabase-upgrade.sql** một lần, sau khi đã tạo bảng và policies theo các bước hướng dẫn.
2. Kiểm tra Authentication > Users có tài khoản admin và bảng `public.admins` có UID tương ứng.
3. Vào Supabase > Project Settings > API Keys / Connect, lấy **Project URL** và **publishable/anon key**.
4. Điền vào `config.js` rồi chạy lại Live Server. KHÔNG sử dụng `service_role`/secret key.
5. Mở Quản trị, đăng nhập, thêm/sửa/xóa/duyệt câu.

## Triển khai GitHub Pages
Đẩy các file vào GitHub repository; Settings > Pages > Deploy from branch > main > /(root). Dữ liệu sẽ nằm ở Supabase, không nằm trong GitHub.

## Lưu ý
- SQL nâng cấp giả định các policy `Anyone can read approved phrases`, `Anyone can submit pending phrases`, `Admins can read all phrases`, `Admins can insert phrases`, `Admins can update phrases`, `Admins can delete phrases` đã được tạo đúng như hướng dẫn trước.
- Cần bổ sung chống spam/rate limit và xác thực bot trước khi public rộng rãi.
- Có thể chỉnh sửa `examples` trong `app.js` để thay câu mẫu khi chưa cấu hình Supabase. Khi đã kết nối, hãy dùng Admin để sửa dữ liệu thật.
