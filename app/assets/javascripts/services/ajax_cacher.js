let store = {};
let queue = [];

const queueLimit = 100;
const enabled = true;// false;

function updateQueue(url, noDelete) {
  if (queue.includes(url)) {
    queue = queue.subtract(url);
  }
  queue.push(url);

  while (!noDelete && queue.length > queueLimit) {
    const entry = queue.shift();
    delete store[entry];
  }
}

function getUriPart(url) {
  return url.replace(/https?:\/\/[^/]+/, '');
}

export default {
  cache(url) {
    const uri = getUriPart(url);
    if (!enabled || uri in store || uri === '') {
      return;
    }

    store[uri] = $.ajax({
      url: `${document.location.protocol}//${document.location.host}${uri}`,
      data: null,
      dataType: 'json',
      success(data, _status, _xhr) {
        store[uri] = data;
        updateQueue(uri, true);
      }
    });
  },
  push(url, data) {
    if (!enabled) {
      return;
    }
    if ('next_page' in data && data.next_page) {
      this.cache(data.next_page);
    }
    if ('prev_page' in data && data.prev_page) {
      this.cache(data.prev_page);
    }
    store[url] = data;
    updateQueue(url);
  },
  get(url) {
    if (enabled && url in store) {
      updateQueue(url);

      if ('next_page' in store[url] && store[url].next_page) {
        this.cache(store[url].next_page); // eslint-disable-line react/no-this-in-sfc
      }
      if ('prev_page' in store[url] && store[url].prev_page) {
        this.cache(store[url].prev_page); // eslint-disable-line react/no-this-in-sfc
      }

      return store[url];
    }
    return null;
  },
  clear(url) {
    delete store[url];
  },
  reset() {
    store = {};
  }
};
