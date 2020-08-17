import View from 'views/application/view';
import { bind } from 'shiki-decorators';
import { animatedCollapse, animatedExpand } from 'helpers/animated';

export default class SpoilerBlock extends View {
  initialize() {
    this.button = this.node.children[0];
    this.content = this.node.children[1];

    this.button.addEventListener('click', this._toggle);
  }

  @bind
  async _toggle(e) {
    e.preventDefault();

    // remove :focus on mouse click (event has x=0,y=0 when pressed space on focused node)
    if (e.x || e.y) { this.button.blur(); }

    const wasOpened = this.node.classList.contains('is-opened');

    if (wasOpened) {
      await animatedCollapse(this.content);
      requestAnimationFrame(() => this.node.classList.remove('is-opened'));
    } else {
      this.node.classList.add('is-opened');
      animatedExpand(this.content);
    }

  }
}
