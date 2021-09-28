import bindings from './bindings';

export default (...args) => {
  const adjustedLength = Math.max(args.length, 1);
  const conditions = args.slice(0, adjustedLength - 1);
  const callback = args[adjustedLength - 1];

  bindings['turbolinks:load'].push({ conditions, callback });
};
