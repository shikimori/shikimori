import { bind } from 'shiki-decorators';
import View from 'views/application/view';

export class PredefinedCheckbox extends View {
  initialize(regexp) {
    this.cssTemplate = this.$root.data('css_template');
    this.regexp = regexp;

    this.$input = this.$('input');
    [this.input] = this.$input;

    this.$input.on('change', this._syncState);
  }

  update(css) {
    this.hasBorder = this._extract(css);
    this.input.checked = this.hasBorder;
  }

  _extract(css) {
    return !!css.match(this.regexp);
  }

  @bind
  _syncState() {
    this.hasBorder = this.input.checked;
    this.trigger('component:update', [this.regexp, this._compile()]);
  }

  _compile() {
    if (!this.hasBorder) { return ''; }

    return this.cssTemplate;
  }
}
