/* global importScripts */
import View from '@/views/application/view';

const NO_HIGHLIGHT = 'nohighlight';

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

    this.klass.worker.postMessage({
      node_id: node.id,
      code: node.textContent,
      language
    });
  }

  // hljs usage example https://highlightjs.org/usage/
  static hljsInitialize() {
    if (this.hljsInitialized) { return; }
    this.hljsInitialized = true;
    this.lastId = 0;

    this.worker = this.buildWorker(function() {
      importScripts(
        'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/10.7.2/highlight.min.js'
      );

      this.onmessage = function(event) {
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
