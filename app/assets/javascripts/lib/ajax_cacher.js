var AjaxCacher = (function() {
  var store = {};
  var queue = [];
  var queue_limit = 30;
  var enabled = false;

  // обновление очереди - переданный url будет помещен в конец, и будут удалены лишние элементы, если очередь разрослась
  function update_queue(url, no_delete) {
    if (_.include(queue, url)) {
      queue = _.without(queue, url);
    }
    queue.push(url);
    while (!no_delete && queue.length > queue_limit) {
      var entry = queue.shift();
      //console.log('delete cache: '+entry);
      delete store[entry];
    }
  }
  // выделение из урла части после /
  function get_uri_part(url) {
    return url.replace(/http:\/\/[^\/]+/, '');
  }

  return {
    enable: function() {
      enabled = true;
    },
    cache: function(url) {
      var uri = get_uri_part(url);
      if (!enabled || uri in store || uri == '') {
        return;
      }
      //console.log('caching: '+url);

      var self = this;
      store[uri] = $.ajax({
        url: location.protocol+"//"+location.host+uri,
        data: null,
        dataType: 'json',
        //beforeSend : function(xhr) {
          //xhr.setRequestHeader("Accept", "application/json");
          //xhr.setRequestHeader("Content-Type", "application/json");
        //},
        success: function (data, status, xhr) {
          //console.log('cached: '+url);
          store[uri] = data;
          update_queue(uri, true);
        },
      });
    },
    push: function(url, data) {
      if (!enabled) {
        return;
      }
      //console.log('push: '+url);
      if ('next_page' in data && data.next_page) {
        this.cache(data.next_page);
      }
      if ('prev_page' in data && data.prev_page) {
        this.cache(data.prev_page);
      }
      store[url] = data;
      update_queue(url);
    },
    get: function(url) {
      if (enabled && url in store) {
        //console.log('get cache: '+url);
        update_queue(url);

        if ('next_page' in store[url] && store[url].next_page) {
          this.cache(store[url].next_page);
        }
        if ('prev_page' in store[url] && store[url].prev_page) {
          this.cache(store[url].prev_page);
        }

        return store[url];
      } else {
        //console.log('get null: '+url);
        return null;
      }
    },
    clear: function(url) {
      delete store[url];
    },
    reset: function() {
      store = {};
    }
  };
})();
