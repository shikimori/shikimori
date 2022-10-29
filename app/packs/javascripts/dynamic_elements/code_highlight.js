/* global importScripts */
import View from '@/views/application/view';
import shikiMarkdown from 'shiki-editor/src/utils/lowlight/shiki_markdown';
import JSONfn from 'json-fn';

const NO_HIGHLIGHT = 'nohighlight';
let shikiMarkdownJSONfn = null;

export default class CodeHighlight extends View {
  initialize() {
    this.klass = CodeHighlight;
    this.klass.hljsInitialize();

    this.highlight();
  }

  highlight() {
    const node = this.root.childNodes[0];
    const language = this.root.attributes['data-language']?.value;

    if (
      node.classList.contains(NO_HIGHLIGHT) ||
      !language ||
      !('Blob' in window) ||
      !('Worker' in window)
    ) { return; }

    node.id = `code_${this.klass.lastId}`;
    this.klass.lastId += 1;
    shikiMarkdownJSONfn ||= JSONfn.stringify(shikiMarkdown);

    this.klass.worker.postMessage({
      node_id: node.id,
      code: node.textContent,
      language,
      shikiMarkdownJSONfn
    });
  }

  // hljs usage example https://highlightjs.org/usage/
  static hljsInitialize() {
    if (this.hljsInitialized) { return; }
    this.hljsInitialized = true;
    this.lastId = 0;

    this.worker = this.buildWorker(function() {
      importScripts(
        'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.6.0/highlight.min.js'
        // requested them to add json-fn https://github.com/cdnjs/packages/issues/1380
        // 'https://cdnjs.cloudflare.com/ajax/libs/json-fn/1.1.1/jsonfn.js'
      );

      // https://raw.githubusercontent.com/vkiryukhin/jsonfn/master/jsonfn.js
      const parseJSONfn = function(str, date2obj) {
        var iso8061 = date2obj ?
          /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}(?:\.\d*)?)Z$/ :
          false;

        return JSON.parse(str, function(key, value) {
          var prefix;

          if (typeof value != 'string') {
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

      this.onmessage = function(event) {
        if (!self.hljs.listLanguages().includes('shiki')) {
          self.hljs.registerLanguage('shiki', parseJSONfn(event.data.shikiMarkdownJSONfn));
        }

        const result = self // eslint-disable-line no-restricted-globals
          .hljs
          .highlight(event.data.language, event.data.code, true);

        postMessage({
          html: result.value,
          node_id: event.data.node_id
        });
      };
    });

    this.worker.onmessage = event => {
      const node = document.getElementById(event.data.node_id);
      if (node) {
        node.innerHTML = event.data.html;
      }
    };
  }

  static buildWorker(func) {
    let code = func.toString();
    code = code.substring(code.indexOf('{') + 1, code.lastIndexOf('}'));

    const blob = new Blob([code], { type: 'application/javascript' });

    return new Worker(URL.createObjectURL(blob));
  }
}
