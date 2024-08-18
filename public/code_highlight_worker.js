/* global importScripts */
importScripts(
  'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js'
);

// https://raw.githubusercontent.com/vkiryukhin/jsonfn/master/jsonfn.js
const parseJSONfn = function(str, date2obj) {
  const iso8061 = date2obj ?
    /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}(?:\.\d*)?)Z$/ :
    false;
  return JSON.parse(str, function(key, value) {
    let prefix;
    if (typeof value !== 'string') {
      return value;
    }
    if (value.length < 8) {
      return value;
    }
    prefix = value.substring(0, 8);
    if (iso8061 && value.match(iso8061)) {
      return new Date(value);
    }
    if (prefix === 'function') {
      return eval('(' + value + ')');
    }
    if (prefix === '_PxEgEr_') {
      return eval(value.slice(8));
    }
    if (prefix === '_NuFrRa_') {
      return eval(value.slice(8));
    }
    return value;
  });
};

self.onmessage = function(event) {
  if (!self.hljs.getLanguage('shiki')) {
    self.hljs.registerLanguage('shiki', parseJSONfn(event.data.shikiMarkdownJSONfn));
  }
  if (!self.hljs.getLanguage('js')) {
    self.hljs.registerAliases('js', { languageName: 'javascript' });
  }
  if (!self.hljs.getLanguage('sass')) {
    self.hljs.registerAliases('sass', { languageName: 'scss' });
  }
  const hljsLanguage = self.hljs.getLanguage(event.data.language);
  if (!hljsLanguage) { return; }

  const result = self
    .hljs
    .highlight(hljsLanguage.name, event.data.code, true);

  postMessage({
    html: result.value,
    node_id: event.data.node_id
  });
};

