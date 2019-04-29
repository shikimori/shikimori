import { bind } from 'decko';
import View from 'views/application/view';

const REGEXP = /\/\* AUTO=page_border \*\/ \.l-page\b.*[\r\n]?/;

export default class PageBorder extends View {
  initialize() {
    this.cssTemplate = this.$root.data('css_template');
    this.$input = this.$('input');
    [this.input] = this.$input;

    this.$input.on('change', this._syncState);
  }

  update(css) {
    this.hasBorder = this._extract(css);
    this.input.checked = this.hasBorder;
  }

  _extract(css) {
    return !!css.match(REGEXP);
  }

  @bind
  _syncState() {
    this.hasBorder = this.input.checked;
    this.trigger('component:update', [REGEXP, this._compile()]);
  }

  _compile() {
    if (!this.hasBorder) { return ''; }

    return this.cssTemplate;
  }
}
