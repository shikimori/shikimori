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

  static hljsInitialize() {
    if (this.hljsInitialized) { return; }
    this.hljsInitialized = true;
    this.lastId = 0;

    this.worker = new Worker('/code_highlight_worker.js');

    this.worker.onmessage = event => {
      const node = document.getElementById(event.data.node_id);
      if (node) {
        node.innerHTML = event.data.html;
      }
    };
  }
}
