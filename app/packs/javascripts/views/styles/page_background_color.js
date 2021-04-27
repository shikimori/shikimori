import { debounce } from 'throttle-debounce';

import View from '@/views/application/view';

const REGEXP = /\/\* AUTO=page_background_color.*?rgba\((\d+), (\d+), (\d+), (\d+).*[\r\n]?/;
const ZERO_OPACITY = 255;
const DEFAULT_OPACITIES = [ZERO_OPACITY, ZERO_OPACITY, ZERO_OPACITY, 1];

export class PageBackgroundColor extends View {
  async initialize() {
    [this.slider] = this.$('.range-slider');
    this.css_template = this.$root.data('css_template');

    this.initPromise = import('nouislider')
      .then(noUiSlider => this._initSlider(noUiSlider));
  }

  async update(css) {
    await this.initPromise;

    this.opacities = this._extract(css);
    const opacity = ZERO_OPACITY - this.opacities.first();
    this._silenced(() => this.slider.noUiSlider.set(opacity));
  }

  _initSlider(noUiSlider) {
    noUiSlider.create(this.slider, {
      range: {
        min: 0,
        max: 12
      },
      start: 0
    }
    );

    this._silenced(() => this.slider.noUiSlider.on('update', () => this._debouncedSync()));
  }

  _extract(css) {
    const matches = css.match(REGEXP);

    if (matches) {
      return matches.slice(1, 5).map(v => parseFloat(v).round());
    }
    return DEFAULT_OPACITIES;
  }

  _debouncedSync() {
    if (!this._syncLambda) {
      this._syncLambda = debounce(100, () => this._syncState());
    }
    if (!this.isSilenced) {
      this._syncLambda();
    }
  }

  _syncState() {
    const opacity = ZERO_OPACITY - parseFloat(this.slider.noUiSlider.get()).round();
    this.opacities = [opacity, opacity, opacity, this.opacities[3]];
    this.trigger('component:update', [REGEXP, this._compile()]);
  }

  _compile() {
    if (this.opacities[0] === ZERO_OPACITY) {
      return '';
    }

    return this.css_template
      .replace(/%d/, this.opacities[0])
      .replace(/%d/, this.opacities[1])
      .replace(/%d/, this.opacities[2])
      .replace(/%d/, this.opacities[3])
      .replace(/%d/, this.opacities[0])
      .replace(/%d/, this.opacities[1])
      .replace(/%d/, this.opacities[2]);
  }

  _silenced(lambda) {
    this.isSilenced = true;
    lambda();
    this.isSilenced = false;
  }
}
