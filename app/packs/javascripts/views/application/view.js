import { chain } from 'shiki-decorators';

export default class View {
  constructor(node, ...args) {
    this._initialize(node);
    this.initialize(...args);
    this._afterInitialize();
  }

  @chain
  on(...args) {
    this.$node.on(...args);
  }

  trigger(...args) {
    this.$node.trigger(...args);
  }

  $(selector) {
    return $(selector, this.$node);
  }

  html(html) {
    return this.$node.html(html);
  }

  _initialize(node) {
    this._setRoot(node);
  }

  _afterInitialize() {}

  _setRoot(node) {
    this.$node = $(node);
    this.$root = this.$node;
    this.node = this.$node[0];
    this.root = this.node;

    this.$node.view(this);
  }
}
