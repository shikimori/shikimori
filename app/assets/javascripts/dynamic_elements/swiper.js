import Swiper from 'swiper';

import ShikiView from 'views/application/shiki_view';
import Wall from 'views/wall/view';
import WallCluster from 'views/wall/cluster';

export default class ShikiSwiper extends ShikiView {
  async initialize() {
    console.log('swiper', this.root);
    await this.$root.imagesLoaded();

    const width = this.$root.width();
    let height;

    if (width > 400) {
      height = 160;
    } else {
      height = (width / (16.0 / 9.0)).round();
    }
    this.$root.css('max-height', height);

    await new Wall(this.$root, {
      isOneCluster: true,
      maxWidth: 9999,
      awaitImagesLoaded: false
    });

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
