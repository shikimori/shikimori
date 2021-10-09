import Comment from './comment';

export default class Message extends Comment {
  _type() { return 'message'; }
  _typeLabel() { return I18n.t('frontend.dynamic_elements.message.type_label'); }
}
