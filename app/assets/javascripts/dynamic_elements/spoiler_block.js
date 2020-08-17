import View from 'views/application/view';
import { bind } from 'shiki-decorators';

export default class SpoilerBlock extends View {
  initialize() {
    this.button = this.node.children[0];
    this.button.addEventListener('click', this._toggle);
  }

  @bind
  _toggle({ x, y }) {
    this.node.classList.toggle('is-opened');

    // is is really mouse click
    if (x || y) {
      this.button.blur();
    }
  }
}
