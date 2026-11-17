# ربط Corner Café بـ Supabase

1. **أنشئ مشروع** على supabase.com.
2. **SQL Editor** ← الصق محتوى `supabase/schema.sql` كامل ← Run.
   (بينشئ الجداول + الأمان + مخزن الصور + التحديث المباشر + القائمة الحالية).
3. **Authentication ← Users ← Add user**: أنشئ حساب المدير (إيميل + كلمة مرور، فعّل Auto Confirm).
   بعدها **Authentication ← Sign In / Providers**: عطّل **Allow new users to sign up** (مهم، وإلا أي شخص ممكن يسجّل ويعدّل).
4. **Project Settings ← API**: انسخ Project URL و anon (أو publishable) key وحطهم في `config.js`.
   ممنوع تحط service_role key.
5. `git add . && git commit -m "supabase" && git push` ← Vercel بينشر تلقائياً.
6. افتح `/admin` وسجّل دخول بالحساب اللي أنشأته.

ملاحظة: الصور القديمة صارت ملفات داخل `img/` بدل ما تكون مدموجة بالـ HTML. الصور اللي بترفعها من لوحة التحكم بتروح على Supabase Storage.
