import SwiperComponent from 'swiper';
import memoize from 'memoize-decorator';

import ShikiView from 'views/application/shiki_view';
import Wall from 'views/wall/view';
import WallCluster from 'views/wall/cluster';

const RATIO = 16.0 / 9;

export default class Swiper extends ShikiView {
  async initialize() {
    const [areaWidth, areaHeight] = this.computeSizes();
    this.setHeight(areaHeight);

    this.root.classList.add('is-loading');
    const hasFailed = await this.imagesLoaded();
    this.root.classList.remove('is-loading');

    if (hasFailed && this.$images.length === 1) {
      this.root.classList.add('is-placeholder');
    } else if (this.$images.length === 1) {
      this.initializeImage(areaWidth, areaHeight);
    } else {
      this.initializeWallOrSwiper(areaWidth, areaHeight);
    }
  }

  get width() {
    return this.$root.width().floor();
  }

  get isAlignCover() {
    return this.align === 'cover';
  }

  @memoize
  get align() {
    return this.$root.data('swiper-align') || 'contain';
  }

  @memoize
  get desiredHeight() {
    return this.$root.data('swiper-height') || 160;
  }

  @memoize
  get $links() {
    return this.$root.children('a');
  }

  @memoize
  get $images() {
    return this.$root.find('img');
  }

  initializeWallOrSwiper(areaWidth, areaHeight) {
    const wall = this.buildWall();

    if (!wall.images.length) {
      this.setPlaceholder(areaWidth, areaHeight);
    } else if (this.width < areaWidth && this.isAlignCover) {
      this.scaleWall(wall, areaWidth);
    } else if (wall.images.length > 1) {
      this.buildSwiper();
    }
  }

  initializeImage(areaWidth, areaHeight) {
    const image = this.$images[0];
    const imageWidth = image.naturalWidth;
    const imageHeight = image.naturalHeight;

    const imageRatio = imageWidth / imageHeight;
    const areaRatio = areaWidth / areaHeight;

    const isVertical = imageRatio < areaRatio;
    const isHorizontal = imageRatio > areaRatio;

    if (isVertical) {
      if (this.isAlignCover) {
        this.alignVertical(areaWidth, areaHeight, imageRatio);
      } else {
        this.$images.css('height', areaHeight);
      }
    }

    if (isHorizontal) {
      if (this.isAlignCover) {
        this.alignHorizontal(areaWidth, areaHeight, imageRatio);
      } else {
        this.$images.css('width', areaWidth);
      }
    }

    this.$links.shikiImage();
  }

  alignVertical(areaWidth, areaHeight, imageRatio) {
    const scaledImageHeight = areaWidth / imageRatio;
    const visiblePercent = ((areaHeight / scaledImageHeight) * 100).round(2);

    const marginTopPercent = [
      10,
      (100 - visiblePercent) / 2
    ].min();

    this.$links.css('margin-top', marginTopPercent > 0 ? `-${marginTopPercent}%` : '');
    this.$images.css('width', areaWidth);
  }

  alignHorizontal(areaWidth, areaHeight, imageRatio) {
    const scaledImageWidth = areaHeight * imageRatio;
    const visiblePercent = ((areaWidth / scaledImageWidth) * 100).round(2);

    const marginLeftPercent = (100 - visiblePercent) / 2;

    this.$links.css('margin-left', marginLeftPercent > 0 ? `-${marginLeftPercent}%` : '');
    this.$images.css('height', areaHeight);
  }

  computeSizes() {
    const { width } = this;
    let height;

    if (width > 400) {
      height = this.desiredHeight;
    } else {
      height = (width / RATIO).floor();
    }

    return [width, height];
  }

  setHeight(height) {
    this.$root.css('max-height', height);
  }

  async imagesLoaded() {
    let hasFailed = false;

    await this.$root.imagesLoaded().catch(() => hasFailed = true);

    if (this.$('.dynamically-replaced').length) {
      // when thumbnail of video is broken, then it is replaced to shikimori custom thumbnail image
      await this.$root.imagesLoaded().catch(() => hasFailed = true);
    }
    return hasFailed;
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
    this.$root
      .css({ width, height })
      .addClass('is-placeholder');
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
