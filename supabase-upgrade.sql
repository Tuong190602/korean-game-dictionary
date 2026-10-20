-- Chạy một lần trong SQL Editor SAU KHI đã tạo bảng phrases/admins và cấp UID admin.
-- Đồng bộ cấu trúc với website, bổ sung cột contributor còn thiếu.
ALTER TABLE public.phrases ADD COLUMN IF NOT EXISTS contributor text NOT NULL DEFAULT '';
-- Nếu database tạo theo hướng dẫn trước, cần bảo đảm quyền theo bảng.
GRANT SELECT ON public.phrases TO anon, authenticated;
GRANT INSERT ON public.phrases TO anon, authenticated;
GRANT UPDATE, DELETE ON public.phrases TO authenticated;
GRANT SELECT ON public.admins TO authenticated;
-- Giữ nguyên các policy đã tạo ở bước 5-8; RLS vẫn bật.
ALTER TABLE public.phrases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admins ENABLE ROW LEVEL SECURITY;
-- Ngăn khách cố gắng gửi câu với trạng thái đã duyệt dù dùng API ngoài website.
CREATE OR REPLACE FUNCTION public.force_pending_for_guests()
RETURNS trigger LANGUAGE plpgsql SET search_path = '' AS $$
BEGIN
 IF NOT EXISTS (SELECT 1 FROM public.admins WHERE user_id = auth.uid()) THEN
   NEW.status := 'pending';
 END IF;
 RETURN NEW;
END; $$;
DROP TRIGGER IF EXISTS trg_force_pending_for_guests ON public.phrases;
CREATE TRIGGER trg_force_pending_for_guests BEFORE INSERT ON public.phrases
FOR EACH ROW EXECUTE FUNCTION public.force_pending_for_guests();
-- Nếu đã chạy SQL ban đầu của project với GRANT UPDATE(status) theo cột,
-- cần cấp thêm các cột để admin có thể chỉnh sửa toàn bộ câu.
GRANT UPDATE (korean,vietnamese,romanization,category,contributor,status) ON public.phrases TO authenticated;
-- Các policy CRUD cho admin (idempotent).
DO $$ BEGIN
 IF NOT EXISTS(SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='phrases' AND policyname='Admin insert all') THEN
 CREATE POLICY "Admin insert all" ON public.phrases FOR INSERT TO authenticated
 WITH CHECK (EXISTS(SELECT 1 FROM public.admins WHERE user_id=(SELECT auth.uid())));
 END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='phrases' AND policyname='Admin delete all') THEN
 CREATE POLICY "Admin delete all" ON public.phrases FOR DELETE TO authenticated
 USING (EXISTS(SELECT 1 FROM public.admins WHERE user_id=(SELECT auth.uid())));
 END IF;
END $$;
-- Lưu ý: cần chống spam/rate-limit trước khi chia sẻ rộng.
