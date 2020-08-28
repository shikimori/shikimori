/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import Topic from './topic';

export default class ShortDialog extends Topic {
  initialize() {
    this._check_height();
    this.on('appear', this._appear);

    // по клику на Ответить помечаем сущность прочитанной
    return this.$('.item-reply').on('click', e => {
      this.$('.b-new_marker.active').click();
      return true;
    });
  }

  // private functions
  _check_height() {
    return this.$inner.checkHeight({
      max_height: this.MAX_PREVIEW_HEIGHT,
      collapsed_height: this.COLLAPSED_HEIGHT
    });
  }

  _type() { return 'dialog'; }
  _type_label() { return I18n.t('frontend.dynamic_elements.dialog.type_label'); }
}
