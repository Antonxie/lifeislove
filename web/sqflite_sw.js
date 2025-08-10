importScripts('https://cdn.jsdelivr.net/npm/sql.js@1.8.0/dist/sql-wasm.js');

const CACHE_NAME = 'sqflite-cache-v1';
const urlsToCache = [
  'https://cdn.jsdelivr.net/npm/sql.js@1.8.0/dist/sql-wasm.wasm'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        return cache.addAll(urlsToCache);
      })
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then((response) => {
        if (response) {
          return response;
        }
        return fetch(event.request);
      }
    )
  );
});

// Initialize SQL.js
self.addEventListener('message', async (event) => {
  if (event.data && event.data.type === 'INIT_SQL') {
    try {
      const SQL = await initSqlJs({
        locateFile: file => `https://cdn.jsdelivr.net/npm/sql.js@1.8.0/dist/${file}`
      });
      self.postMessage({ type: 'SQL_READY', SQL });
    } catch (error) {
      self.postMessage({ type: 'SQL_ERROR', error: error.message });
    }
  }
});