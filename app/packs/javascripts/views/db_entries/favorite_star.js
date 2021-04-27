import { bind } from 'shiki-decorators';
import View from '@/views/application/view';

const ADD_CLASS = 'fav-add';
const REMOVE_CLASS = 'fav-remove';

export class FavoriteStar extends View {
  initialize(isFavoured) {
    this.addText = this.$root.data('add_text');
    this.removeText = this.$root.data('remove_text');
    this._update(isFavoured);

    this.on('ajax:success', this._ajaxSuccess);
  }

  @bind
  _ajaxSuccess() {
    this._update(this.root.classList.contains(ADD_CLASS));
  }

  _update(isFavoured) {
    if (isFavoured) {
      this.$root
        .removeClass(ADD_CLASS)
        .addClass(REMOVE_CLASS)
        .attr({
          title: this.removeText,
          'original-title': this.removeText,
          // do not use "data" mthod, because this value is used in css
          'data-text': this.removeText
        })
        .data('method', 'delete');
    } else {
      this.$root
        .removeClass(REMOVE_CLASS)
        .addClass(ADD_CLASS)
        .attr({
          title: this.addText,
          'original-title': this.addText,
          // do not use "data" mthod, because this value is used in css
          'data-text': this.addText
        })
        .data('method', 'post');
    }
  }
}
