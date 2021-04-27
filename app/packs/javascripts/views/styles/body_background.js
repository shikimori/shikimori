import { bind } from 'shiki-decorators';
import View from 'views/application/view';

const REGEXP = /\/\* AUTO=body_background.*?body { background: url\((.+?)\)(.*)}.*[\r\n]?/;

export class BodyBackground extends View {
  initialize() {
    this.cssTemplate = this.$root.data('css_template');
    [this.input] = this.$('#body_background_input');
    [this.repeat] = this.$('#body_background_repeat');
    [this.fixed] = this.$('#body_background_fixed');
    [this.left] = this.$('#body_background_left');
    [this.top] = this.$('#body_background_top');
    [this.right] = this.$('#body_background_right');
    [this.bottom] = this.$('#body_background_bottom');

    this.$('input').on('paste keyup change', this._syncState);
    this.$('.prepared-backgrounds li').on('click', this._preparedBackground);
  }

  update(css) {
    [
      this.backgroundUrl,
      this.isRepeat,
      this.isFixed,
      this.isLef,
      this.isTop,
      this.isRight,
      this.is_bototm
    ] = Array.from(this._extract(css));

    this.input.value = this.backgroundUrl || '';
    this.repeat.checked = this.isRepeat;
    this.fixed.checked = this.isFixed;
    this.left.checked = this.isLef;
    this.top.checked = this.isTop;
    this.right.checked = this.isRight;
    this.bottom.checked = this.isBottom;
  }

  @bind
  _syncState() {
    this.backgroundUrl = this.input.value;
    this.isRepeat = this.repeat.checked;
    this.isFixed = this.fixed.checked;
    this.isLef = this.left.checked;
    this.isTop = this.top.checked;
    this.isRight = this.right.checked;
    this.isBottom = this.bottom.checked;

    this.trigger('component:update', [REGEXP, this._compile()]);
  }

  @bind
  _preparedBackground(e) {
    this.input.value = $(e.target).data('background');
    this.repeat.checked = true;
    this.fixed.checked = false;
    this.left.checked = false;
    this.top.checked = false;
    this.right.checked = false;
    this.bottom.checked = false;

    this._syncState();
  }

  _extract(css) {
    const matches = css.match(REGEXP);

    if (!matches) { return []; }

    return [
      matches[1],
      matches[2].match(/ repeat\b/, ''),
      matches[2].match(/ fixed\b/, ''),
      matches[2].match(/ left\b/, ''),
      matches[2].match(/ top\b/, ''),
      matches[2].match(/ right\b/, ''),
      matches[2].match(/ bottom\b/, '')
    ];
  }

  _compile() {
    if (!this.backgroundUrl) { return ''; }

    const options = [this.isRepeat ? 'repeat' : 'no-repeat'];

    if (this.isFixed) { options.push('fixed'); }
    if (this.isLef) { options.push('left'); }
    if (this.isTop) { options.push('top'); }
    if (this.isRight) { options.push('right'); }
    if (this.isBottom) { options.push('bottom'); }

    const css = `url(${this.backgroundUrl}) ${options.join(' ')}`;

    return this.cssTemplate.replace(/%s/, css);
  }
}
