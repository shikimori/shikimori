import Comment from './comment';

export default class Message extends Comment {
  get type() { return 'message'; }
  get typeLabel() { return I18n.t('frontend.dynamic_elements.message.type_label'); }

  _deactivateInaccessibleButtons() {
  }
}
