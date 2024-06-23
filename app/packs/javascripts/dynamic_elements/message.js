import Comment from './comment';
import I18n from '@/utils/i18n';

export default class Message extends Comment {
  get type() { return 'message'; }
  get typeLabel() { return I18n.t('frontend.dynamic_elements.message.type_label'); }

  _deactivateInaccessibleButtons() {
  }
}
