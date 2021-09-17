import Topic from './topic';

export default class Summary extends Topic {
  _type() { return 'dialog'; }
  _typeLabel() { return I18n.t('frontend.dynamic_elements.summary.type_label'); } // eslint-disable-line camelcase

  initialize() {
    this._checkHeight();
    this.on('appear', this._appear);
  }
}
