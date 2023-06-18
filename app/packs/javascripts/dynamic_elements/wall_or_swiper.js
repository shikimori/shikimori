import Swiper from './swiper';
import View from '@/views/application/view';
import Wall from '@/views/wall/view';

import { isPhone } from 'shiki-utils';

let GLOBAL_HANDLER = false;

const GLOBAL_SELECTOR = 'b-shiki_swiper,.b-shiki_wall';
const DATA_KEY = 'wall_or_swiper';

function setHanler() {
  GLOBAL_HANDLER = true;
  $(document).on('resize:debounced orientationchange', update);
}

function update() {
  $(`.${GLOBAL_SELECTOR}`).each((_index, node) => (
    $(node).data(DATA_KEY)?.update()
  ));
}

export default class WallOrSwiper extends View {
  initialize() {
    if (!GLOBAL_HANDLER) { setHanler(); }
    this.$node.data(DATA_KEY, this);

    this.update();
  }

  get isPhone() {
    return isPhone();
  }

  update() {
    if (this.isPhone && !this.$node.data('wall_always')) {
      this._updatePhone();
    } else {
      this._updateDesktop();
    }
  }

  _updatePhone() {
    if (this.wall) {
      this.wall.destroy();
      this.wall = null;
    }

    if (this.swiper) {
      this.swiper.update(true);
    } else {
      this._buildSwiper();
    }
  }

  _updateDesktop() {
    if (this.swiper) {
      this.swiper.destroy();
      this.swiper = null;
    }

    if (this.wall) {
      this.wall.update();
    } else {
      this._buildWall();
    }
  }

  _buildSwiper() {
    this.node.classList.remove('b-shiki_wall');
    this.node.classList.add('b-shiki_swiper');

    this.swiper = new Swiper(this.node, false);
  }

  _buildWall() {
    this.node.classList.add('b-shiki_wall');
    this.node.classList.remove('b-shiki_swiper');

    this.wall = new Wall(this.node);
  }
}
