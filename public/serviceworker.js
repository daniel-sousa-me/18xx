'use strict';

self.addEventListener('push', function(event) {
  var data = event.data.json()
  var icon = '/images/logo_polygon_yellow.svg';

  event.waitUntil(
    self.registration.showNotification(data['title'], {
      body: data['body'],
      icon: icon,
      data: data
    })
  );
});

self.addEventListener('notificationclick', function(event) {
  console.log('On notification click: ', event.notification.tag);
  // Android doesn’t close the notification when you click on it
  // See: http://crbug.com/463146
  event.notification.close();

  // This looks to see if the current is already open and
  // focuses if it is
  event.waitUntil(clients.matchAll({
    type: 'window'
  }).then(function(clientList) {
    for (var i = 0; i < clientList.length; i++) {
      var client = clientList[i];
      if (client.url === event.notification.data['url'] && 'focus' in client) {
        return client.focus();
      }
    }
    if (clients.openWindow) {
      return clients.openWindow( event.notification.data['url']);
    }
  }));
});

const cache_dirs = ['assets', 'icons', 'images', 'logos', 'pinned'];
const cache_prefix = 'static-';

async function create_cache(version) {
  const cache = await caches.open(cache_prefix + version.hash);
  await cache.addAll(version.static_files);
}

async function fetch_from_cache_and_fallback(cache, request) {
  const cachedResponse = await cache.match(request);
  if (cachedResponse) return cachedResponse;

  const networkResponse = await fetch(request);
  event.waitUntil(
    cache.put(request, networkResponse.clone())
  );
  return networkResponse;
}

addEventListener('install', event => {
  event.waitUntil(async function() {
    // When using this worker for the first time, check for the latest version of the site
    await fetch('assets/version.json').then(response => {
      // Creates a cache with this version and fetches the static files
      var version = response.json().then(version => {
        if(version) {
          create_cache(version);
        }
      });
    });
  }());
});

addEventListener('activate', event => {
  event.waitUntil(async function(s) {
    // When starting the page, check for the latest version of the site
    await fetch('assets/version.json').then(response => {
      response.json().then(version => {
        if(version) {
          console.log("Reseting cache")
          s.version = version
          // Checks if there's already a cache for this version
          caches.has(cache_prefix + s.version.hash).then(has_cache => {
            if(!has_cache) {
              // If it doesn't, deletes all caches
              caches.keys().then(function (cacheNames) {
                cacheNames.map(function (cacheName) {
                  if(chacheName.startsWith(cache_prefix)) {
                    return caches.delete(cacheName);
                  }
                });
              });
              // And then creates a new one and fetches the static files
              create_cache(s.version);
            }
          });
        }
      });
    });
  }(self));
});

addEventListener('fetch', (event) => {
  event.respondWith(async function(s) {
    if(s.version && s.version.static_files && s.version.static_files.includes(new URL(event.request.url).pathname.substring(1))) {
      // If this is a static file, look for it in the cache.
      // If it's not found, fetch it and store
      // Here we consider static files, the ones caught by Rake (which supposedly are already stored),
      // but also others that it may have missed
      const cache = await caches.open(cache_prefix + s.version.hash);

      return await fetch_from_cache_and_fallback(cache, event.request);
    } else if(event.request.url.split("/")[3] == 'pinned') {
      // We store pinned games in a separate cache, because they don't need to be refreshed
      // TODO: Check if there are many pinned_js's that are no longer needed and offer the user the option to free some space
      const cache = await caches.open('pinned_js');

      return await fetch_from_cache_and_fallback(cache, event.request);
    } else {
      // Otherwise (api, message-bus and other dynamic pages) skip our cache entirely
      return fetch(event.request).catch(() => {
        if(s.version && event.request.destination == 'document') {
          return caches.open(cache_prefix + s.version.hash).then(function(cache) {
            return cache.match('offline');
          });
        }
      });
    }
  }(self));
});

//addEventListener('fetch', (event) => {
//
//  const { request } = event;
//
//  // Always bypass for range requests, due to browser bugs
//  if (request.headers.has('range')) return;
//  event.respondWith(async function() {
//    // Try to get from the cache:
//    const cachedResponse = await caches.match(request);
//    if (cachedResponse) return cachedResponse;
//
//    try {
//      // See https://developers.google.com/web/updates/2017/02/navigation-preload#using_the_preloaded_response
//      const response = await event.preloadResponse;
//      if (response) return response;
//
//      // Otherwise, get from the network
//      return await fetch(request);
//    } catch (err) {
//      // If this was a navigation, show the offline page:
//      if (request.mode === 'navigate') {
//        return caches.match('offline');
//      }
//
//      // Otherwise throw
//      throw err;
//    }
//  }());
//});
