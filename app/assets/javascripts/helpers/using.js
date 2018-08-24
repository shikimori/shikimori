window.using = names => {
  let scope = window;

  return names.split('.').forEach(name => {
    if (!scope[name]) { scope[name] = {}; }
    return scope = scope[name];
  });
};
