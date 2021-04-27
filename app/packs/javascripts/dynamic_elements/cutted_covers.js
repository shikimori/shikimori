import delay from 'delay';
import View from '@/views/application/view';

let PRIOR_ID = 0;
let GLOBAL_HANDLER = false;

export const GLOBAL_SELECTOR = 'd-cutted_covers';
export const DATA_KEY = 'cutted-covers';

export const RATIO = {
  entry: 318.0 / 225.0,
  person: 350.0 / 225.0,
  character: 350.0 / 225.0
};

function update() {
  $('#injectCSSContainer').empty();

  $(`.${GLOBAL_SELECTOR}`).each((_index, node) => (
    $(node).data(DATA_KEY)?.injectCss()
  ));
}

function setHanler() {
  GLOBAL_HANDLER = true;
  $(document).on('resize:debounced orientationchange', update);
}

export class CuttedCovers extends View {
  async initialize() {
    if (!GLOBAL_HANDLER) { setHanler(); }

    // $.process иногда выполняется ДО вставки в DOM, а этот код должен быть
    // выполнен, когда уже @root вставлен в DOM. поэтому delay
    await delay();

    this._fetchPoster();
    this.collection_id = `cutted_covers_${this.incrementId()}`;
    this.ratio_value = RATIO[this.nodeRatio(this.node)] || RATIO.entry;

    this.injectCss();

    this.node.id = this.collection_id;
    this.node.classList.add(GLOBAL_SELECTOR);

    this.$node.data(DATA_KEY, this);
  }

  injectCss() {
    if (!this.$poster || !$.contains(document.documentElement, this.$poster[0])) {
      this._fetchPoster();
    }
    const height = (this.$poster.width() * this.ratio_value).round(2);
    const width = this.$poster.width();

    if ((width > 0) && (height > 0)) {
      $.injectCSS({
        [`#${this.collection_id}`]: {
          '.image-cutter': {
            'max-width': width,
            'max-height': height
          }
        }
      });
    }
  }

  incrementId() {
    return PRIOR_ID += 1;
  }

  nodeRatio(node) {
    return node.attributes['data-ratio_type']?.value;
  }

  _fetchPoster() {
    this.$poster = this.$('.b-catalog_entry:first-child .image-decor');
  }
}
