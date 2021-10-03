import { bind, memoize } from 'shiki-decorators';
import { isPhone } from 'shiki-utils';

import Topic from './topic';
import Turbolinks from 'turbolinks';

export default class Review extends Topic {
  _type() { return 'review'; }
  _typeLabel() { return I18n.t('frontend.dynamic_elements.review.type_label'); } // eslint-disable-line camelcase

  initialize() {
    const mobileOffset = isPhone() ? 63 : 0;

    this.CHECK_HEIGHT_MAX_PREVIEW_HEIGHT = 220 + mobileOffset;
    this.CHECK_HEIGHT_COLLAPSED_HEIGHT = 170 + mobileOffset;
    this.CHECK_HEIGHT_PLACEHOLDER_HEIGHT = 115 + mobileOffset;

    super.initialize();
    this._scheduleCheckHeight();
  }

  @memoize
  get $checkHeightNode() {
    return this.$inner;
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
  _redirectAfterDeleted(_e, result) {
    Turbolinks.visit(
      document.location.href.replace(/\/reviews\/\d+$/, '/reviews'),
      { action: 'replace' }
    );
  }
}
