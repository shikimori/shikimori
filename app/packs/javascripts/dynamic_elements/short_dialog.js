import Topic from './topic';
import I18n from '@/utils/i18n';

export default class ShortDialog extends Topic {
  initialize() {
    this._scheduleCheckHeight(false);
    this.on('appear', this._appear);

    // по клику на ответить помечаем сущность прочитанной
    this.$('.item-reply').on('click', () => {
      this.$('.b-new_marker.active').click();
    });
  }

  _deactivateInaccessibleButtons() {}

  get type() { return 'dialog'; }
  get commentType() { return 'message'; }
  get typeLabel() { return I18n.t('frontend.dynamic_elements.dialog.type_label'); }
  get $checkHeightNode() { return this.$inner; }
}
