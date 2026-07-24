const CACHE_NAME = 'plexo360-v36';
const ASSETS = ['./','./index.html','./manifest.json','./plexo-icon-192.png','./plexo-icon-512.png'];
self.addEventListener('install', function(e){ e.waitUntil(caches.open(CACHE_NAME).then(function(c){return c.addAll(ASSETS);})); self.skipWaiting(); });
self.addEventListener('activate', function(e){ e.waitUntil(caches.keys().then(function(ks){return Promise.all(ks.filter(function(k){return k!==CACHE_NAME;}).map(function(k){return caches.delete(k);}));})); self.clients.claim(); });
self.addEventListener('fetch', function(e){
  if(e.request.method!=='GET') return;
  var url=e.request.url;
  if(url.includes('firebasejs')||url.includes('googleapis')||url.includes('firestore')||url.includes('sheetjs')||url.includes('supabase')||url.includes('gstatic')){ e.respondWith(fetch(e.request).catch(function(){return caches.match(e.request);})); return; }
  var isDoc = e.request.mode==='navigate'||url.endsWith('/')||url.endsWith('index.html');
  if(isDoc){ e.respondWith(fetch(e.request).then(function(r){ if(r&&r.status===200){var c=r.clone();caches.open(CACHE_NAME).then(function(ca){ca.put(e.request,c);});} return r; }).catch(function(){ return caches.match(e.request).then(function(c){return c||caches.match('./index.html');}); })); return; }
  e.respondWith(caches.match(e.request).then(function(cached){ var fp=fetch(e.request).then(function(r){ if(r&&r.status===200){var c=r.clone();caches.open(CACHE_NAME).then(function(ca){ca.put(e.request,c);});} return r; }).catch(function(){return cached;}); return cached||fp; }));
});