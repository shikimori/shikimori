import Topic from './topic';

export default class ShortDialog extends Topic {
  initialize() {
    this._scheduleCheckHeight(false);
    this.on('appear', this._appear);

    // по клику на ответить помечаем сущность прочитанной
    this.$('.item-reply').on('click', () => {
      this.$('.b-new_marker.active').click();
    });
  }

  get type() { return 'dialog'; }
  get commentType() { return 'message'; }
  get typeLabel() { return I18n.t('frontend.dynamic_elements.dialog.type_label'); } // eslint-disable-line camelcase
  get $checkHeightNode() { return this.$inner; }
}
