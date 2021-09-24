import Topic from './topic';

export default class Review extends Topic {
  _type() { return 'review'; }
  _typeLabel() { return I18n.t('frontend.dynamic_elements.review.type_label'); } // eslint-disable-line camelcase

  initialize() {
    this.MAX_PREVIEW_HEIGHT = 200;
    this.COLLAPSED_HEIGHT = 150;

    this.$body = this.$inner.children('.body');

    this._checkHeight();
    this.on('appear', this._appear);
  }

  _checkHeight() {
    if (!this.$body.hasClass('check_height')) { return; }

    this.$body.checkHeight({
      maxHeight: this.MAX_PREVIEW_HEIGHT,
      collapsedHeight: this.COLLAPSED_HEIGHT
    });
  }
}
