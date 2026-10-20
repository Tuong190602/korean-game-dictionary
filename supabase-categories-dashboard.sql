-- Chạy một lần trong Supabase SQL Editor, sau các bước tạo phrases/admins.
CREATE TABLE IF NOT EXISTS public.categories (
 name text PRIMARY KEY CHECK (length(trim(name)) BETWEEN 1 AND 70),
 icon text NOT NULL DEFAULT '📁',
 sort_order integer NOT NULL DEFAULT 100,
 created_at timestamptz NOT NULL DEFAULT now()
);
INSERT INTO public.categories(name,icon,sort_order) VALUES
('Giao tiếp cơ bản','☏',10),('Nhóm & Tổ đội','♟',20),('Boss & Dungeon','⚔',30),
('Mua bán & Giao dịch','◇',40),('Trang bị & Nâng cấp','✦',50),('PvP & Chiến đấu','⚒',60),
('Cảm xúc','♡',70),('Hỗ trợ & Yêu cầu','☏',80)
ON CONFLICT(name) DO NOTHING;
-- Bảo tồn danh mục từ các câu đã lưu trước đó.
INSERT INTO public.categories(name,icon,sort_order)
SELECT DISTINCT trim(category),'📁',100 FROM public.phrases
WHERE category IS NOT NULL AND length(trim(category)) BETWEEN 1 AND 70
ON CONFLICT(name) DO NOTHING;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Everyone can view categories" ON public.categories;
CREATE POLICY "Everyone can view categories" ON public.categories FOR SELECT TO anon,authenticated USING (true);
DROP POLICY IF EXISTS "Admins insert categories" ON public.categories;
CREATE POLICY "Admins insert categories" ON public.categories FOR INSERT TO authenticated
WITH CHECK (EXISTS (SELECT 1 FROM public.admins WHERE user_id=(SELECT auth.uid())));
-- Sửa/xóa danh mục chỉ qua các hàm atomic bên dưới.
CREATE OR REPLACE FUNCTION public.admin_update_category(old_name text,new_name text,new_icon text,new_sort_order integer)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
BEGIN
 IF NOT EXISTS(SELECT 1 FROM public.admins WHERE user_id=auth.uid()) THEN RAISE EXCEPTION 'Admin required'; END IF;
 IF length(trim(new_name)) NOT BETWEEN 1 AND 70 THEN RAISE EXCEPTION 'Invalid name'; END IF;
 IF old_name<>trim(new_name) THEN
   INSERT INTO public.categories(name,icon,sort_order) VALUES(trim(new_name),left(coalesce(new_icon,'📁'),12),new_sort_order);
   UPDATE public.phrases SET category=trim(new_name) WHERE category=old_name;
   DELETE FROM public.categories WHERE name=old_name;
 ELSE
   UPDATE public.categories SET icon=left(coalesce(new_icon,'📁'),12),sort_order=new_sort_order WHERE name=old_name;
 END IF;
END $$;
CREATE OR REPLACE FUNCTION public.admin_delete_category(old_name text,destination_name text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
BEGIN
 IF NOT EXISTS(SELECT 1 FROM public.admins WHERE user_id=auth.uid()) THEN RAISE EXCEPTION 'Admin required'; END IF;
 IF old_name=destination_name OR NOT EXISTS(SELECT 1 FROM public.categories WHERE name=destination_name) THEN RAISE EXCEPTION 'Invalid destination'; END IF;
 UPDATE public.phrases SET category=destination_name WHERE category=old_name;
 DELETE FROM public.categories WHERE name=old_name;
END $$;
REVOKE ALL ON FUNCTION public.admin_update_category(text,text,text,integer) FROM PUBLIC,anon;
REVOKE ALL ON FUNCTION public.admin_delete_category(text,text) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.admin_update_category(text,text,text,integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_delete_category(text,text) TO authenticated;
