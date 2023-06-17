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
      if (window.SHIKI_USER.id == 1) { console.log(`WallOrSwiper.isPhone=${isPhone()}`); }
    return isPhone();
  }

  update() {
    if (this.isPhone && !this.$node.data('wall_always')) {
      if (window.SHIKI_USER.id == 1) { console.log('WallOrSwiper.update -> updatePhone'); }
      this._updatePhone();
    } else {
      if (window.SHIKI_USER.id == 1) { console.log('WallOrSwiper.update -> updateDesktop'); }
      this._updateDesktop();
    }
  }

  _updatePhone() {
    if (this.wall) {
      this.wall.destroy();
      this.wall = null;
    }

    if (this.swiper) {
      if (window.SHIKI_USER.id == 1) { console.log('WallOrSwiper.updatePhone -> swiper.update'); }
      this.swiper.update(true);
    } else {
      if (window.SHIKI_USER.id == 1) { console.log('WallOrSwiper.updatePhone -> buildSwiper'); }
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
    if (window.SHIKI_USER.id == 1) { console.log('WallOrSwiper.buildSwiper', this.swiper); }
  }

  _buildWall() {
    this.node.classList.add('b-shiki_wall');
    this.node.classList.remove('b-shiki_swiper');

    this.wall = new Wall(this.node);
  }
}
