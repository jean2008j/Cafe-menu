// قيم مشروع Supabase (Project Settings → API)
// الـ anon key مصمَّم يكون علني (الحماية الفعلية من RLS). لا تحط هون أبداً الـ service_role key.
window.CAFE_CONFIG = {
  // إيميل المدير الثابت (داخلي، ما بينكتب بصفحة الدخول). لازم يطابق المستخدم المنشأ بـ Supabase
  ADMIN_EMAIL: "admin@cornercafe.app",
  // رابط القائمة اللي بيطلع منه رمز الـ QR
  MENU_URL: "https://cafe-menu-jet-nine.vercel.app/",
  SUPABASE_URL: "https://yhnzbgmlabmkmfsdwwxh.supabase.co",
  SUPABASE_ANON_KEY: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlobnpiZ21sYWJta21mc2R3d3hoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQ5MzU3OTUsImV4cCI6MjExMDUxMTc5NX0.DnadtaP9s-liroSxF5TTykA7oKQqCA9BY8Chbo7qLvo"
};
