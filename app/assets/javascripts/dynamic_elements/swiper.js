import SwiperComponent from 'swiper';
import memoize from 'memoize-decorator';

import View from 'views/application/view';
import Wall from 'views/wall/view';
import WallCluster from 'views/wall/cluster';

const CLASS_NAME = 'b-shiki_swiper';
let GLOBAL_HANDLER = false;
const RATIO = 16.0 / 9;

function setHanler() {
  GLOBAL_HANDLER = true;
  $(document).on('resize:debounced orientationchange', update);
}

function update() {
  $(`.${CLASS_NAME}`).each((_index, node) => (
    $(node).view()?.update()
  ));
}

export default class Swiper extends View {
  async initialize() {
    if (!GLOBAL_HANDLER) { setHanler(); }

    this.computeSizes();
    this.$root.css('max-height', this.areaHeight);

    this.root.classList.add('is-loading');
    const hasFailed = await this.imagesLoaded();
    this.root.classList.remove('is-loading');

    if ((hasFailed && this.$images.length === 1) || !this.$images.length) {
      this.root.classList.add('is-placeholder');
      return;
    }

    this.update();
  }

  get width() {
    return this.$root.width().floor();
  }

  @memoize
  get isAlignCover() {
    return this.align === 'cover';
  }

  @memoize
  get align() {
    return this.$root.data('swiper-align') || 'contain';
  }

  @memoize
  get desiredHeight() {
    return this.$root.data('swiper-height') || 0;
  }

  @memoize
  get isVideo() {
    return this.$root.children('.b-video').length;
  }

  @memoize
  get $links() {
    return this.$root.children();
  }

  @memoize
  get $images() {
    return this.$links.find('img');
  }

  update() {
    if (this.$images.length === 1) {
      this.initializeImage();
    } else {
      this.initializeWallOrSwiper();
    }
  }

  initializeWallOrSwiper() {
    const wall = this.buildWall();

    if (!wall.images.length) {
      this.setPlaceholder();
    } else if (this.width < this.areaWidth && this.isAlignCover) {
      this.scaleWall(wall, this.areaWidth);
    } else if (wall.images.length > 1) {
      this.buildSwiper();
    }
  }

  initializeImage() {
    const image = this.$images[0];
    const imageWidth = image.naturalWidth;
    const imageHeight = image.naturalHeight;

    const imageRatio = imageWidth / imageHeight;
    const areaRatio = this.areaWidth / this.areaHeight;

    const isVertical = imageRatio < areaRatio;
    const isHorizontal = imageRatio > areaRatio;

    if (isVertical) {
      if (this.isAlignCover) {
        this.alignVertical(imageRatio);
      } else {
        this.$images.css('height', this.areaHeight);
      }
    }

    if (isHorizontal) {
      if (this.isAlignCover) {
        this.alignHorizontal(imageRatio);
      } else {
        this.$images.css('width', this.areaWidth);
      }
    }

    if (this.isVideo) {
      this.$links.shikiVideo();
    } else {
      this.$links.shikiImage();
    }
  }

  alignVertical(imageRatio) {
    const scaledImageHeight = this.areaWidth / imageRatio;
    const scaleRatio = this.areaHeight / scaledImageHeight;
    const visiblePercent = scaleRatio * 100;

    const marginTopPercent = [
      10,
      ((100 - visiblePercent) / 2 / scaleRatio).round(2)
    ].min();

    if (!this.isVideo) {
      this.$links.css('margin-top', marginTopPercent > 0 ? `-${marginTopPercent}%` : '');
    }
    this.$images.css('width', this.areaWidth);
  }

  alignHorizontal(imageRatio) {
    const scaledImageWidth = this.areaHeight * imageRatio;
    const scaleRatio = this.areaWidth / scaledImageWidth;
    const visiblePercent = scaleRatio * 100;

    const marginLeftPercent = ((100 - visiblePercent) / 2 / scaleRatio).round(2);

    if (!this.isVideo) {
      this.$links.css('margin-left', marginLeftPercent > 0 ? `-${marginLeftPercent}%` : '');
    }
    this.$images.css('height', this.areaHeight);
  }

  computeSizes() {
    const { width } = this;
    let height;

    if (this.desiredHeight !== 0) {
      height = this.desiredHeight;
    } else {
      height = (width / RATIO).floor();
    }

    this.areaWidth = width;
    this.areaHeight = height;
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
