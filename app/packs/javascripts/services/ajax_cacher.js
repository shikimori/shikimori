import axios from '@/utils/axios';

let store = {};
let queue = [];

const queueLimit = 300;

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
  fetch(url) {
    if (store[url]) {
      return store[url];
    }

    const promise = axios
      .get(url)
      .catch(({ response }) => {
        delete store[url];
        return { status: response.status, data: response.data };
      });

    store[url] = promise;

    updateQueue(url);

    return promise;
  },
  // clear(url) {
    // delete store[url];
  // },
  reset() { // used in recommendations
    store = {};
  }
};
