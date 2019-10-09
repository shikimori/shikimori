import SwiperComponent from 'swiper';

import ShikiView from 'views/application/shiki_view';
import Wall from 'views/wall/view';
import WallCluster from 'views/wall/cluster';

const RATIO = 16.0 / 9;

export default class Swiper extends ShikiView {
  async initialize() {
    const [areaWidth, areaHeight] = this.computeSizes();
    this.setHeight(areaHeight);

    await this.imagesLoaded();

    const wall = this.buildWall();

    if (!wall.images.length) {
      this.setPlaceholder(areaWidth, areaHeight);
    } else if (this.width < areaWidth) {
      this.scaleWall(wall, areaWidth);
    } else if (wall.images.length > 1) {
      this.buildSwiper();
    }
  }

  get width() {
    return this.$root.width().floor();
  }

  computeSizes() {
    const { width } = this;
    let height;

    if (width > 400) {
      height = 160;
    } else {
      height = (width / RATIO).floor();
    }

    return [width, height];
  }

  setHeight(height) {
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

    new SwiperComponent(this.root, {
      slidesPerView: 'auto',
      spaceBetween: WallCluster.MARGIN,
      a11y: false
    });
  }

  setPlaceholder(width, height) {
    this.$root.css({ width, height });
  }

  scaleWall(wall, width) {
    const firstImage = wall.images.first();
    if (wall.images.length === 1 && firstImage.ratio > RATIO) {
      return;
    }

    const newWall = new Wall(this.$root, {
      isOneCluster: true,
      maxWidth: width,
      maxHeight: 9999,
      awaitImagesLoaded: false
    });

    newWall.images.forEach((image, index) => {
      if (index > 0) {
        image.$root.css({ left: '', 'margin-left': WallCluster.MARGIN });
      }
    });
  }
}
