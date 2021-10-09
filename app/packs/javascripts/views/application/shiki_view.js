import delay from 'delay';
import { bind, memoize } from 'shiki-decorators';

import View from '@/views/application/view';
import axios from '@/utils/axios';
import checkHeight from '@/utils/check_height';
import { imagePromiseFinally } from '@/utils/load_image';

const SPOILER_CLASSES = ['.b-spoiler', '.b-spoiler_block'];

// общий класс для комментария, топика, редактора
export default class ShikiView extends View {
  _initialize(...args) {
    super._initialize(...args);

    this.CHECK_HEIGHT_MAX_PREVIEW_HEIGHT = 450;
    this.CHECK_HEIGHT_COLLAPSED_HEIGHT = 150;
    this.CHECK_HEIGHT_PLACEHOLDER_HEIGHT = 0;

    this.$node.removeClass('unprocessed');
    this.$inner = this.$('>.inner');
  }

  destroy() {
    this.$node.off();
    super.destroy();
  }

  @memoize
  get $checkHeightNode() {
    return this.$inner;
  }

  async _scheduleCheckHeight(isSkipClassCheck = false) {
    if (!isSkipClassCheck && this.$checkHeightNode.data('check_height') !== '') {
      return;
    }

    let imageNodes = this.$checkHeightNode.find('img').toArray();
    const $spoilers = this.$checkHeightNode.find(SPOILER_CLASSES.join(','));

    if ($spoilers.length) {
      imageNodes = imageNodes.subtract($spoilers.find('img').toArray());
    }

    if (imageNodes.length) {
      // картинки могут быть уменьшены image_normalizer'ом, поэтому делаем с задержкой
      await imagePromiseFinally(imageNodes);
    }
    await delay(10);
    this._checkHeight();
  }

  @bind
  _checkHeight() {
    if (!window.SHIKI_USER.isCommentsAutoCollapsed) { return; }

    checkHeight(this.$checkHeightNode, {
      maxHeight: this.CHECK_HEIGHT_MAX_PREVIEW_HEIGHT,
      collapsedHeight: this.CHECK_HEIGHT_COLLAPSED_HEIGHT,
      placeholderHeight: this.CHECK_HEIGHT_PLACEHOLDER_HEIGHT
    });
  }

  @bind
  _shade() {
    return this.$inner.addClass('b-ajax');
  }

  @bind
  _unshade() {
    return this.$inner.removeClass('b-ajax');
  }

  @bind
  async _reload() {
    this._shade();
    const { data } = await axios.get(this._reloadUrl());
    this._replace(data.content, data.JS_EXPORTS, this.$inner !== this.$node);
  }

  // урл для перезагрузки элемента
  _reloadUrl() {
    return this.$node.data('url');
  }

  _replace(html, JS_EXPORTS, isReplaceInner = false) {
    const htmlWoCheckHeight = html.replace(' data-check_height', '');

    if (isReplaceInner) {
      this._replaceInner(htmlWoCheckHeight, JS_EXPORTS);
    } else {
      this._replaceNode(htmlWoCheckHeight, JS_EXPORTS);
    }
  }

  async _replaceInner(html, JS_EXPORTS) {
    const $replaced = $(html).children('.inner');
    this.destroy();
    this.$inner.replaceWith($replaced);

    this.$node
      .addClass('to-process')
      .process(JS_EXPORTS);

    this.$('>.inner').yellowFade();
  }

  _replaceNode(html, JS_EXPORTS) {
    const $replaced = $(html);
    this.$node.replaceWith($replaced);

    $replaced.process(JS_EXPORTS);
    $replaced.yellowFade();
  }
}
