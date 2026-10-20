-- Chạy toàn bộ SQL này trong Supabase SQL Editor.
create extension if not exists pgcrypto;
create table if not exists public.phrases (
 id uuid primary key default gen_random_uuid(),
 korean text not null check (char_length(trim(korean)) between 1 and 250),
 vietnamese text not null check (char_length(trim(vietnamese)) between 1 and 250),
 romanization text not null default '' check (char_length(romanization)<=250),
 category text not null check (category in ('Giao tiếp cơ bản','Nhóm & Tổ đội','Boss & Dungeon','Mua bán & Giao dịch','Trang bị & Nâng cấp','PvP & Chiến đấu','Cảm xúc','Hỗ trợ & Yêu cầu')),
 contributor text not null default '' check (char_length(contributor)<=60),
 status text not null default 'pending' check (status in ('pending','approved','rejected')),
 created_at timestamptz not null default now()
);
create table if not exists public.admins (
 user_id uuid primary key references auth.users(id) on delete cascade
);
alter table public.phrases enable row level security;
alter table public.admins enable row level security;
-- Public chỉ xem câu đã duyệt.
create policy "Public read approved" on public.phrases for select to anon,authenticated using (status='approved' or exists(select 1 from public.admins where user_id=(select auth.uid())));
-- Chỉ admin được xem bảng admins, và chỉ xem chính mình.
create policy "Admin checks self" on public.admins for select to authenticated using (user_id=(select auth.uid()));
-- Khách gửi đề xuất, không được đặt trạng thái thành approved.
create policy "Submit pending" on public.phrases for insert to anon,authenticated with check (status='pending');
-- Chỉ admin được duyệt hoặc từ chối.
create policy "Admin update" on public.phrases for update to authenticated using (exists(select 1 from public.admins where user_id=(select auth.uid()))) with check (exists(select 1 from public.admins where user_id=(select auth.uid())));
-- Khóa quyền theo cột: trình duyệt chỉ được thêm các trường dữ liệu hợp lệ.
revoke all on public.phrases from anon,authenticated;
grant select on public.phrases to anon,authenticated;
grant insert (korean,vietnamese,romanization,category,contributor,status) on public.phrases to anon,authenticated;
grant update (status) on public.phrases to authenticated;
revoke all on public.admins from anon,authenticated;
grant select on public.admins to authenticated;
-- Sau khi tạo user quản trị trong Authentication > Users, chạy riêng:
-- insert into public.admins(user_id) values ('UUID_CUA_TAI_KHOAN_ADMIN');
-- Lưu ý: bản đầu tiên chưa có chống spam/CAPTCHA, hãy thêm trước khi chia sẻ rộng.
