// Service worker بسيط: بس بيخزّن شكل اللوحة (admin) للفتح السريع. ما بيلمس بيانات Supabase أبداً.
const CACHE="admin-shell-v1";
const SHELL=["/admin.html","/config.js","/icons/icon-192.png"];
self.addEventListener("install",e=>{e.waitUntil(caches.open(CACHE).then(c=>c.addAll(SHELL)).then(()=>self.skipWaiting()))});
self.addEventListener("activate",e=>{e.waitUntil(caches.keys().then(k=>Promise.all(k.filter(x=>x!==CACHE).map(x=>caches.delete(x)))).then(()=>self.clients.claim()))});
self.addEventListener("fetch",e=>{
  const u=new URL(e.request.url);
  if(e.request.method!=="GET"||u.origin!==location.origin)return;
  if(!SHELL.includes(u.pathname)&&u.pathname!=="/admin")return;
  // الشبكة أولاً (دايماً أحدث نسخة)، والكاش فقط إذا انقطع الإنترنت
  e.respondWith(fetch(e.request).then(r=>{const c=r.clone();caches.open(CACHE).then(x=>x.put(e.request,c));return r}).catch(()=>caches.match(e.request).then(r=>r||caches.match("/admin.html"))));
});
