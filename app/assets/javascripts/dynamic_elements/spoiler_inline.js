import View from 'views/application/view';
import { bind } from 'shiki-decorators';

export default class SpoilerInline extends View {
  initialize() {
    this.node.addEventListener('click', this._toggle);
  }

  @bind
  async _toggle(e) {
    // prevent form submition
    e.preventDefault();

    // remove :focus on mouse click (event has x=0,y=0 when pressed space on focused node)
    if (e.x || e.y) { this.node.blur(); }

    this.node.classList.toggle('is-opened');
  }
}
