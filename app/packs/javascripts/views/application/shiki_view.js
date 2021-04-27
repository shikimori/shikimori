import { bind } from 'shiki-decorators';

import View from 'views/application/view';
import axios from 'helpers/axios';

// общий класс для комментария, топика, редактора
export default class ShikiView extends View {
  MAX_PREVIEW_HEIGHT = 450
  COLLAPSED_HEIGHT = 150

  _initialize(...args) {
    super._initialize(...args);

    this.$node.removeClass('unprocessed');
    this.$inner = this.$('>.inner');

    // if (!this.$inner.exists()) { return; }
  }

  @bind
  _checkHeight() {
    if (!window.SHIKI_USER.isCommentsAutoCollapsed) { return; }

    this.$inner.checkHeight({
      maxHeight: this.MAX_PREVIEW_HEIGHT,
      collapsedHeight: this.COLLAPSED_HEIGHT
    });
  }

  @bind
  _shade() {
    return this.$node.addClass('b-ajax');
  }

  @bind
  _unshade() {
    return this.$node.removeClass('b-ajax');
  }

  @bind
  async _reload() {
    this._shade();
    const { data } = await axios.get(this._reloadUrl());
    this._replace(data.content, data.JS_EXPORTS);
  }

  // урл для перезагрузки элемента
  _reloadUrl() {
    return this.$node.data('url');
  }

  _replace(html, JS_EXPORTS) {
    const $replaced = $(html);
    this.$node.replaceWith($replaced);

    $replaced
      .process(JS_EXPORTS)
      .yellowFade();
  }
}
