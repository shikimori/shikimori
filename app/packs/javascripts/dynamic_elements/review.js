import Topic from './topic';
import { memoize } from 'shiki-decorators';

export default class Review extends Topic {
  _type() { return 'review'; }
  _typeLabel() { return I18n.t('frontend.dynamic_elements.review.type_label'); } // eslint-disable-line camelcase

  initialize() {
    this.CHECK_HEIGHT_MAX_PREVIEW_HEIGHT = 220;
    this.CHECK_HEIGHT_COLLAPSED_HEIGHT = 170;
    this.CHECK_HEIGHT_PLACEHOLDER_HEIGHT = 115;

    // data attribute is set in Topics.Tracker
    this.model = this.$node.data('model') || this._defaultModel();

    this.$body = this.$inner.children('.body');

    if (this.model) { this._actualizeVoting(); }
    this._bindVotes();

    this._scheduleCheckHeight();
    this.on('appear', this._appear);
  }

  @memoize
  get $checkHeightNode() {
    return this.$inner;
  }
}
