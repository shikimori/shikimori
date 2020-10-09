import Comment from './comment';

export default class Message extends Comment {
  _type() { return 'message'; }
  _type_label() { return I18n.t('frontend.dynamic_elements.message.type_label'); }

  _deactivate_inaccessible_buttons() {}
}
