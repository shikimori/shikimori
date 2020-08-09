import View from 'views/application/view';
import { bind } from 'shiki-decorators';

export default class SpoilerInline extends View {
  initialize() {
    this.node.addEventListener('click', this._toggle);
  }

  @bind
  _toggle(currentTarget) {
    this.node.classList.toggle('is-opened');
  }
}
