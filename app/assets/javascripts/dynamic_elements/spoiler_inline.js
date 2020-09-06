import View from 'views/application/view';
import { bind } from 'shiki-decorators';

export default class SpoilerInline extends View {
  initialize() {
    this.node.addEventListener('click', this._toggle);
    this.node.addEventListener('keypress', this._keypress);
    this.node.addEventListener('keydown', this._keydown);
  }

  @bind
  async _toggle(e) {
    // do not prevent clicks on links inside spoiler
    if ((e.x || e.y) && e.target.tagName === 'A') {
      return;
    }

    // prevent form submition
    e.preventDefault();
    e.stopImmediatePropagation();

    // remove :focus on mouse click (event has x=0,y=0 when pressed space on focused node)
    if (e.x || e.y) { this.node.blur(); }

    this.node.classList.toggle('is-opened');
  }

  @bind
  _keypress(e) {
    switch (e.keyCode) {
      case 32: // space
      case 13: // enter
        this._toggle(e);
    }
  }

  @bind
  _keydown(e) {
    switch (e.keyCode) {
      case 27: // esc
        e.preventDefault();
        e.stopImmediatePropagation();

        this.node.blur();
    }
  }
}
