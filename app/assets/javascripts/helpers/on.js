import bindings from './bindings';

window.on = function (event, ...rest) {
  const adjustedLength = Math.max(rest.length, 1);
  const conditions = rest.slice(0, adjustedLength - 1);
  const callback = rest[adjustedLength - 1];

  bindings[event].push({ conditions, callback });
};

window.page_load = function (...args) {
  const adjustedLength = Math.max(args.length, 1);
  const conditions = args.slice(0, adjustedLength - 1);
  const callback = args[adjustedLength - 1];

  bindings['page:load'].push({ conditions, callback });
};

window.page_restore = function (...args) {
  const adjustedLength = Math.max(args.length, 1);
  const conditions = args.slice(0, adjustedLength - 1);
  const callback = args[adjustedLength - 1];

  bindings['page:restore'].push({ conditions, callback });
};

export default {
  on: window.on,
  page_load: window.page_load
};
