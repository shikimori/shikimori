import { bind, memoize } from 'shiki-decorators';
import { isPhone } from 'shiki-utils';
import delay from 'delay';

import Topic from './topic';
import Turbolinks from 'turbolinks';
import { pushFlash } from '@/utils/flash';

export default class Review extends Topic {
  initialize() {
    const mobileOffset = isPhone() ? 63 : 0;

    this.CHECK_HEIGHT_MAX_PREVIEW_HEIGHT = 220 + mobileOffset;
    this.CHECK_HEIGHT_COLLAPSED_HEIGHT = 170 + mobileOffset;
    this.CHECK_HEIGHT_PLACEHOLDER_HEIGHT = 115 + mobileOffset;

    this.$body = this.$inner.find('.body');

    super.initialize();
    this._scheduleCheckHeight();
  }

  get type() { return 'review'; }
  get typeLabel() { return I18n.t('frontend.dynamic_elements.review.type_label'); } // eslint-disable-line camelcase
  get $checkHeightNode() { return this.$inner; }

  @memoize
  get $editorPlacement() {
    return this.$body.parent();
  }

  @bind
  _toggleMobileControls() {
    super._toggleMobileControls();

    const $buttons = this.$inner.children('aside.buttons');
    const $header = this.$inner.children('header');

    if (this.$node.hasClass('aside-expanded')) {
      $buttons.detach();
      $buttons.insertBefore($header);
    } else {
      $buttons.detach();
      $buttons.insertAfter($header);
    }
  }

  @bind
  async _redirectAfterDeleted(_e, result) {
    pushFlash(result.notice);

    await delay(150);
    Turbolinks.visit(
      document.location.href.replace(/\/reviews\/\d+$/, '/reviews'),
      { action: 'replace' }
    );
  }
}
