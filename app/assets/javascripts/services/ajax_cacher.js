// import axios from 'helpers/axios';

let store = {};
let queue = [];
window.z = store;

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

// function getUriPart(url) {
//   return url.replace(/https?:\/\/[^/]+/, '');
// }

export default {
  // cache(url) {
    // const uri = getUriPart(url);
    // url: `${document.location.protocol}//${document.location.host}${url}`,

    // if (!enabled || url in store[url] || Object.isEmpty(url)) {
    //   return;
    // }

    // store[url] = axios
    //   .get(url)
    //   .then(({ data }) => {
    //     store[url] = data;
    //     updateQueue(url, true);
    //   });
  // },
  push(url, data) {
    if (!enabled) { return; }

    // if ('next_page_url' in data && data.next_page_url) {
    //   this.cache(data.next_page_url);
    // }
    // if ('prev_page_url' in data && data.prev_page_url) {
    //   this.cache(data.prev_page_url);
    // }
    store[url] = data;
    updateQueue(url);
  },
  get(url) {
    if (enabled && store[url]) {
      updateQueue(url);

      // if ('next_page_url' in store[url] && store[url].next_page_url) {
      //   this.cache(store[url].next_page_url); // eslint-disable-line react/no-this-in-sfc
      // }
      // if ('prev_page_url' in store[url] && store[url].prev_page_url) {
      //   this.cache(store[url].prev_page_url); // eslint-disable-line react/no-this-in-sfc
      // }

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
