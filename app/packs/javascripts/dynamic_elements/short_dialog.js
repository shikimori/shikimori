import Topic from './topic';
import { memoize } from 'shiki-decorators';

export default class ShortDialog extends Topic {
  _type() { return 'dialog'; }
  _commentType() { return 'message'; }
  _typeLabel() { return I18n.t('frontend.dynamic_elements.dialog.type_label'); } // eslint-disable-line camelcase

  initialize() {
    this._scheduleCheckHeight(false);
    this.on('appear', this._appear);

    // по клику на ответить помечаем сущность прочитанной
    this.$('.item-reply').on('click', () => {
      this.$('.b-new_marker.active').click();
    });
  }

  @memoize
  get $checkHeightNode() {
    return this.$inner;
  }
}
