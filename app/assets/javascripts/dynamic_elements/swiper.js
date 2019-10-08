import Swiper from 'swiper';

import ShikiView from 'views/application/shiki_view';
import Wall from 'views/wall/view';
import WallCluster from 'views/wall/cluster';

export default class SwiperView extends ShikiView {
  async initialize() {
    this.setSizes();
    await this.imagesLoaded();

    const wall = this.buildWall();

    if (wall.images.length > 1) {
      this.buildSwiper();
    }
  }

  setSizes() {
    const width = this.$root.width();
    let height;

    if (width > 400) {
      height = 160;
    } else {
      height = (width / (16.0 / 9.0)).round();
    }
    this.$root.css('max-height', height);
  }

  async imagesLoaded() {
    await this.$root.imagesLoaded();
    if (this.$('.dynamically-replaced').length) {
      // when thumbnail of video is broken, then it is replaced to shikimori custom thumbnail image
      await this.$root.imagesLoaded();
    }
  }

  buildWall() {
    return new Wall(this.$root, {
      isOneCluster: true,
      maxWidth: 9999,
      awaitImagesLoaded: false
    });
  }

  buildSwiper() {
    this.$root.children()
      .addClass('swiper-slide')
      .removeAttr('style')
      .wrapAll('<div class="swiper-wrapper" />');

    new Swiper(this.root, {
      slidesPerView: 'auto',
      spaceBetween: WallCluster.MARGIN,
      a11y: false
    });
  }
}
