import delay from 'delay';
import { bind, memoize } from 'shiki-decorators';

import View from '@/views/application/view';
import axios from '@/helpers/axios';
import { imagePromiseFinally } from '@/helpers/load_image';

// общий класс для комментария, топика, редактора
export default class ShikiView extends View {
  _initialize(...args) {
    super._initialize(...args);

    this.MAX_PREVIEW_HEIGHT = 450;
    this.COLLAPSED_HEIGHT = 150;

    this.$node.removeClass('unprocessed');
    this.$inner = this.$('>.inner');
  }

  @memoize
  get $checkHeightNode() {
    return this.$inner;
  }

  async _scheduleCheckHeight(isSkipClassCheck = false) {
    if (!isSkipClassCheck && !this.$checkHeightNode.hasClass('check_height')) {
      return;
    }

    const $images = this.$checkHeightNode.find('img');

    if ($images.length) {
      // картинки могут быть уменьшены image_normalizer'ом, поэтому делаем с задержкой
      await imagePromiseFinally($images.toArray());
    }
    await delay(10);
    this._checkHeight();
  }

  @bind
  _checkHeight() {
    if (!window.SHIKI_USER.isCommentsAutoCollapsed) { return; }

    this.$checkHeightNode.checkHeight({
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
