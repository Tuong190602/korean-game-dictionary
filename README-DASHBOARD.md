# Korean Game Dictionary — Admin Dashboard

1. Supabase → SQL Editor → New query: chạy `supabase-categories-dashboard.sql` (một lần). KHÔNG chạy lại `supabase.sql` để tránh thay đổi policy hiện tại.
2. Giữ `config.js` đã cấu hình Supabase URL và publishable/anon key; không đưa service_role/secret key vào GitHub.
3. VS Code → Live Server → `index.html` → Quản trị → đăng nhập.
4. Quản lý câu: tìm theo tiếng Hàn, tiếng Việt, phiên âm hoặc người gửi; lọc danh mục/trạng thái; 20 câu/trang; sửa, duyệt, xóa.
5. Danh mục: thêm, đổi tên, đổi emoji, thứ tự; khi xóa, chọn danh mục chuyển câu. Đổi tên/xóa thực hiện trong một giao dịch database qua RPC, tránh mất câu.
6. Khi chạy trên GitHub Pages, cần chính sách chống spam/rate limiting cho biểu mẫu đề xuất công khai. Trước khi công khai rộng rãi nên kiểm tra RLS và thử bằng tài khoản khách.

Lưu ý: các câu mẫu trong app.js chỉ hiển thị khi chưa cấu hình Supabase. Khi kết nối, câu thực được quản lý qua dashboard/database.
