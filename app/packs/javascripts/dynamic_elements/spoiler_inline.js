import { bind } from 'shiki-decorators';

import View from 'views/application/view';
import { getSelectionText, isGetSelectionTextSupported } from 'helpers/get_selection';

export default class SpoilerInline extends View {
  initialize() {
    this.node.addEventListener('click', this._toggle);
    this.node.addEventListener('keypress', this._keypress);
    this.node.addEventListener('keydown', this._keydown);
  }

  @bind
  async _toggle(e) {
    // do not prevent clicks on links inside spoiler
    if ((e.x || e.y) && (
      e.target.tagName === 'A' ||
      e.target.parentNode.tagName === 'A' ||
      e.target.parentNode.parentNode.tagName === 'A' ||
      e.target.parentNode.parentNode.parentNode.tagName === 'A'
    )) {
      return;
    }

    // prevent spoiler from collapse during text selection
    if (this.isOpened && getSelectionText() && isGetSelectionTextSupported()) {
      if (e.currentTarget.contains(window.getSelection().focusNode)) {
        e.currentTarget.blur();
        return;
      }
    }

    // prevent form submition
    e.preventDefault();
    e.stopImmediatePropagation();

    // remove :focus on mouse click (event has x=0,y=0 when pressed space on focused node)
    if (e.x || e.y) { this.node.blur(); }

    this.node.classList.toggle('is-opened');
  }

  get isOpened() {
    return this.node.classList.contains('is-opened');
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
