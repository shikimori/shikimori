import View from 'views/application/view';
import { bind } from 'shiki-decorators';
import { animatedCollapse, animatedExpand } from 'helpers/animated';

export default class SpoilerBlock extends View {
  initialize() {
    [this.button, this.content] = this.node.children;

    this.button.addEventListener('click', this._toggle);
    this.node.addEventListener('keydown', this._keydown);
  }

  @bind
  async _toggle(e) {
    // prevent form submition
    e.preventDefault();

    // remove :focus on mouse click (event has x=0,y=0 when pressed space on focused node)
    if (e.x || e.y) { this.button.blur(); }

    const wasOpened = this.node.classList.contains('is-opened');

    if (wasOpened) {
      this.node.classList.add('is-closing');
      await animatedCollapse(this.content);
      requestAnimationFrame(() => {
        this.node.classList.remove('is-opened');
        this.node.classList.remove('is-closing');
      });
    } else {
      this.node.classList.add('is-opened');
      animatedExpand(this.content);
    }
  }

  @bind
  _keydown(e) {
    switch (e.keyCode) {
      case 27: // esc
        e.preventDefault();
        e.stopImmediatePropagation();

        this.button.blur();
    }
  }
}
