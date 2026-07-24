const CACHE_NAME = 'plexo360-v34';
const ASSETS = [
  './',
  './index.html',
  './manifest.json',
  './plexo-icon-192.png',
  './plexo-icon-512.png'
];

self.addEventListener('install', function(e) {
  e.waitUntil(
    caches.open(CACHE_NAME).then(function(cache) {
      return cache.addAll(ASSETS);
    })
  );
  self.skipWaiting();
});

self.addEventListener('activate', function(e) {
  e.waitUntil(
    caches.keys().then(function(keys) {
      return Promise.all(
        keys.filter(function(k) { return k !== CACHE_NAME; })
            .map(function(k) { return caches.delete(k); })
      );
    })
  );
  self.clients.claim();
});

self.addEventListener('fetch', function(e) {
  if (e.request.method !== 'GET') return;
  var url = e.request.url;

  // Recursos externos (Firebase, Supabase, CDNs): rede primeiro, cache como reserva offline
  if (url.includes('firebasejs') || url.includes('googleapis') || url.includes('firestore') ||
      url.includes('sheetjs') || url.includes('supabase') || url.includes('gstatic')) {
    e.respondWith(
      fetch(e.request).catch(function() { return caches.match(e.request); })
    );
    return;
  }

  // Documento HTML / navegacao: SEMPRE rede primeiro — garante a versao mais recente do app.
  // Cai para o cache apenas se estiver offline.
  var isDoc = e.request.mode === 'navigate' || url.endsWith('/') || url.endsWith('index.html');
  if (isDoc) {
    e.respondWith(
      fetch(e.request).then(function(response) {
        if (response && response.status === 200) {
          var clone = response.clone();
          caches.open(CACHE_NAME).then(function(cache) { cache.put(e.request, clone); });
        }
        return response;
      }).catch(function() {
        return caches.match(e.request).then(function(c) { return c || caches.match('./index.html'); });
      })
    );
    return;
  }

  // Demais assets (icones, manifest): stale-while-revalidate
  e.respondWith(
    caches.match(e.request).then(function(cached) {
      var fetchPromise = fetch(e.request).then(function(response) {
        if (response && response.status === 200) {
          var clone = response.clone();
          caches.open(CACHE_NAME).then(function(cache) { cache.put(e.request, clone); });
        }
        return response;
      }).catch(function() { return cached; });
      return cached || fetchPromise;
    })
  );
});
