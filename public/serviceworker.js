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



const static_files = ['offline', 'new_game_offline']

function create_cache(version) {
  cache = await caches.open('static-' + version).then(function(cache) {
    return cache.addAll(static_files);
  }
}

addEventListener('install', event => {
  event.waitUntil(async function() {
    // When using this worker for the first time, check for the latest version of the site
    await fetch('version.json').then(function(response) {
      version = response.json().hash()
      // Creates a cache with this version and fetches the static files
      const cache = create_cache(version);
    });
  }());
});

addEventListener('activate', event => {
  event.waitUntil(async function() {
    // When starting the page, check for the latest version of the site
    await fetch('version.json').then(function(response) {
      const self.version = response.json().hash()
      // Checks if there's already a cache for this version
      caches.has('static-' + self.version).then(function(has_cache) {
        if(!has_cache) {
          // If it doesn't, deletes all caches
          caches.keys().then(function (cacheNames) {
            cacheNames.map(function (cacheName) {
              return caches.delete(cacheName);
            });
          })
          // And then creates a new one and fetches the static files
          const cache = create_cache(self.version);
        }
      });
    });
  }());
});

addEventListener('fetch', (event) => {
  event.respondWith(async function() {
    if(static_files.includes(event.request.url)) {
      // If this is a static file, look for it in the cache.
      // If it's not found, fetch it and store
      const cache = await caches.open('static-'.sel.version);
      const cachedResponse = await cache.match(event.request);
      if (cachedResponse) return cachedResponse;

      const networkResponse = await fetch(event.request);
      event.waitUntil(
        cache.put(event.request, networkResponse.clone())
      );
      return networkResponse;
    } else {
      // Otherwise (api, message-bus) skip our cache entirely
      event.respondWith(fetch(event.request));
    }
  }());
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
