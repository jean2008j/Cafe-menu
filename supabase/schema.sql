-- =====================================================
--  Corner Café — Supabase schema  (شغّله مرة واحدة في SQL Editor)
--  آمن لإعادة التشغيل: ما بيمسح بياناتك
-- =====================================================

-- 1) الجداول
create table if not exists public.categories (
  id   int  primary key,            -- 1..n (يطابق ترتيب التبويبات)
  name text not null
);

create table if not exists public.menu_items (
  id         text primary key,
  c          int  not null references public.categories(id) on update cascade,
  n          text not null,                      -- الاسم
  d          text not null default '',           -- الوصف
  p          numeric not null default 0 check (p >= 0),  -- السعر
  e          text not null default '🍽️',         -- إيموجي بديل للصورة
  h          int  not null default 30,           -- لون الخلفية (hue)
  t          text,                               -- شارة: الأكثر طلباً / جديد
  ok         boolean not null default true,      -- متوفر؟
  img        text not null default '',           -- رابط الصورة
  sort       int  not null default 0,
  created_at timestamptz not null default now()
);
create index if not exists menu_items_c_idx on public.menu_items(c);

create table if not exists public.settings (
  id   int primary key check (id = 1),           -- صف واحد فقط
  data jsonb not null default '{}'::jsonb
);

-- 2) الأمان (RLS): الكل يقرأ — فقط المدير المسجَّل يعدّل
alter table public.categories enable row level security;
alter table public.menu_items enable row level security;
alter table public.settings   enable row level security;

do $$
declare t text;
begin
  foreach t in array array['categories','menu_items','settings'] loop
    execute format('drop policy if exists "public read" on public.%I', t);
    execute format('drop policy if exists "admin write" on public.%I', t);
    execute format('create policy "public read" on public.%I for select to anon, authenticated using (true)', t);
    execute format('create policy "admin write" on public.%I for all to authenticated using (true) with check (true)', t);
  end loop;
end $$;

-- 3) مخزن الصور
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('menu-images', 'menu-images', true, 2097152, array['image/jpeg','image/png','image/webp'])
on conflict (id) do nothing;

drop policy if exists "menu images read"   on storage.objects;
drop policy if exists "menu images insert" on storage.objects;
drop policy if exists "menu images update" on storage.objects;
drop policy if exists "menu images delete" on storage.objects;
create policy "menu images read"   on storage.objects for select using (bucket_id = 'menu-images');
create policy "menu images insert" on storage.objects for insert to authenticated with check (bucket_id = 'menu-images');
create policy "menu images update" on storage.objects for update to authenticated using (bucket_id = 'menu-images');
create policy "menu images delete" on storage.objects for delete to authenticated using (bucket_id = 'menu-images');

-- 4) تحديث مباشر (Realtime) — الزبون يشوف التعديل بدون ريفرش
do $$
declare t text;
begin
  foreach t in array array['categories','menu_items','settings'] loop
    if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename=t) then
      execute format('alter publication supabase_realtime add table public.%I', t);
    end if;
  end loop;
end $$;

-- 5) البيانات الأولية (نفس القائمة الحالية)
insert into public.categories (id, name) values
  (1, 'مشروبات ساخنة'),
  (2, 'مشروبات باردة'),
  (3, 'حلويات'),
  (4, 'مأكولات خفيفة')
on conflict (id) do nothing;

insert into public.settings (id, data) values (1, '{"name": "Corner Café", "kicker": "قهوة دمشقية منذ 1985", "tag": "قهوة مختارة وحلويات طازجة، بنكهة الشام.", "tables": "مفتوح يومياً 8 ص – 12 م", "logo": "", "color": "", "cur": "SYP", "svc": 0, "url": ""}'::jsonb)
on conflict (id) do nothing;

insert into public.menu_items (id, c, n, d, p, e, h, t, ok, img, sort) values
  ('h1', 1, 'قهوة عربية', 'قهوة مهيّلة بالهيل تُقدَّم بدلّة نحاسية.', 120, '☕', 30, null, true, 'img/h1.jpg', 1),
  ('h2', 1, 'إسبريسو', 'جرعة مركزة من القهوة الغنية مع طبقة كريمية كثيفة.', 100, '☕', 24, null, true, 'img/h2.jpg', 2),
  ('h3', 1, 'كابتشينو', 'مزيج متوازن من الإسبريسو والحليب المبخر مع رغوة غنية ومزينة بالرسم.', 180, '☕', 34, 'الأكثر طلباً', true, 'img/h3.jpg', 3),
  ('h4', 1, 'لاتيه', 'قهوة إسبريسو مع حليب مبخر ورغوة ناعمة.', 200, '🥛', 36, null, true, 'img/h4.jpg', 4),
  ('h5', 1, 'شاي بالنعناع', 'شاي أخضر دافئ بأوراق النعناع الطازجة.', 80, '🍵', 26, null, true, 'img/h5.jpg', 5),
  ('k1', 2, 'آيس لاتيه', 'إسبريسو مركز مع حليب بارد ومكعبات الثلج.', 220, '🧊', 30, null, true, 'img/k1.jpg', 6),
  ('k2', 2, 'ليموناضة بالنعناع', 'عصير ليمون طازج ومنعش مع أوراق النعناع.', 150, '🍋', 60, null, true, 'img/k2.jpg', 7),
  ('k3', 2, 'موهيتو فريز', 'موهيتو فوار بالفراولة الطازجة والنعناع والليمون.', 200, '🍓', 350, 'جديد', true, 'img/k3.jpg', 8),
  ('s1', 3, 'بوظة بالفستق', 'آيس كريم كريمي بنكهة الفستق الحلبي وقطع المقرمشة.', 200, '🍨', 90, null, true, 'img/s1.jpg', 9),
  ('s2', 3, 'براونيز', 'قطع كيك براونيز غنية بالشوكولاتة الداكنة.', 180, '🍫', 20, 'الأكثر طلباً', true, 'img/s2.jpg', 10),
  ('f1', 4, 'كرواسان بالجبنة', 'كرواسون دافئ محشو بالجبنة الذائبة.', 150, '🥐', 40, null, true, 'img/f1.jpg', 11),
  ('p1', 4, 'بوشار', 'فشار طازج ومقرمش مملح بخفة.', 100, '🍿', 44, null, true, 'img/p1.jpg', 12),
  ('f3', 4, 'كرواسان بالشوكولا', 'كرواسون هش محشو ومزين بالشوكولاتة الغنية.', 170, '🥐', 28, null, true, 'img/f3.jpg', 13)
on conflict (id) do nothing;
