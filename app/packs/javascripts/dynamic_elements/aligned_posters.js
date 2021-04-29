import chunk from 'lodash/chunk';
import delay from 'delay';
import { memoize } from 'shiki-decorators';

import View from '@/views/application/view';
import { loadImages } from '@/helpers/load_image';

export const GLOBAL_SELECTOR = 'd-aligned_posters';
export const DATA_KEY = 'cutted-covers';

let GLOBAL_HANDLER = false;

function setHanler() {
  GLOBAL_HANDLER = true;
  $(document).on('resize:debounced orientationchange', update);
}

function update() {
  console.log('update');
  $(`.${GLOBAL_SELECTOR}`).each((_index, node) => (
    $(node).data(DATA_KEY)?.process()
  ));
}

export class AlignedPosters extends View {
  TARGET_SELECTOR = '.image-cutter'

  async initialize() {
    if (!GLOBAL_HANDLER) { setHanler(); }

    this.columns = this.$node.data('columns');

    // $.process sometimes executed BEFORE a node is inserted into the DOM,
    // but this code must executed AFTER a node is inserted into the DOM.
    // that is why `delay` is used here
    await Promise.all([
      delay(),
      loadImages(this.node)
    ]);

    this.process();

    this.node.classList.add(GLOBAL_SELECTOR);
    this.$node.data(DATA_KEY, this);
  }

  @memoize
  get $targets() {
    return this.$node.find(this.TARGET_SELECTOR);
  }

  async process(isSkipCheck) {
    if (!isSkipCheck && this._ensureUntouched()) { return; }

    chunk(this.$targets.toArray(), this.columns)
      .forEach(group => {
        const heights = group
          .map(node => $(node).outerHeight())
          .filter(height => height > 0)
          .sort();

        if (!heights?.[0]) { return; }

        const medianHeight = heights[Math.floor(heights.length / 2)];
        const minimalPossibleHeight = medianHeight * 0.75;
        const height = heights.find(height => height > minimalPossibleHeight);

        if (height > 0) {
          $(group).css('max-height', height);
        }
      });
  }

  _ensureUntouched() {
    if (!this.$targets[0].hasAttribute('style')) { return false; }

    this.$targets.removeAttr('style');
    requestAnimationFrame(() => this.process(true));

    return true;
  }
}
