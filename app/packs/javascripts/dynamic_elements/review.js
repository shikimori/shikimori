import Topic from './topic';
import { memoize } from 'shiki-decorators';

export default class Review extends Topic {
  _type() { return 'review'; }
  _typeLabel() { return I18n.t('frontend.dynamic_elements.review.type_label'); } // eslint-disable-line camelcase

  initialize() {
    this.MAX_PREVIEW_HEIGHT = 200;
    this.COLLAPSED_HEIGHT = 150;

    this.$body = this.$inner.children('.body');

    this._scheduleCheckHeight();
    this.on('appear', this._appear);
  }
}
