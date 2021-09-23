import Topic from './topic';

export default class Review extends Topic {
  _type() { return 'review'; }
  _typeLabel() { return I18n.t('frontend.dynamic_elements.review.type_label'); } // eslint-disable-line camelcase

  initialize() {
    this._checkHeight();
    this.on('appear', this._appear);
  }
}
