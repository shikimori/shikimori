import SwiperComponent from 'swiper';
import memoize from 'memoize-decorator';

import View from 'views/application/view';
import Wall from 'views/wall/view';
import WallCluster from 'views/wall/cluster';

const GLOBAL_SELECTOR = 'b-shiki_swiper';
const DATA_KEY = 'swiper';

let GLOBAL_HANDLER = false;
const RATIO = 16.0 / 9;

function setHanler() {
  GLOBAL_HANDLER = true;
  $(document).on('resize:debounced orientationchange', update);
}

function update() {
  $(`.${GLOBAL_SELECTOR}`).each((_index, node) => (
    $(node).data(DATA_KEY)?.update()
  ));
}

// import delay from 'delay';

export default class Swiper extends View {
  isPlaceholder = false;

  async initialize(isGlobalUpdate = true) {
    if (!GLOBAL_HANDLER) { setHanler(); }
    this.$node.data(DATA_KEY, this);
    this.isGlobalUpdate = isGlobalUpdate;

    this._computeSizes();

    this.root.classList.add('is-loading');
    const hasFailed = await this._imagesLoaded();
    this.root.classList.remove('is-loading');

    if ((hasFailed && this.$images.length === 1) || !this.$images.length) {
      this.isPlaceholder = true;
    }

    this._initializeContent();

    // await delay(500);
    // this.update();
    window.z = this;
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
  get isVideoShrinked() {
    return this.isVideo && this.$root.children('.b-video.shrinked').length;
  }

  @memoize
  get $links() {
    return this.$root.children();
  }

  @memoize
  get $images() {
    return this.$links.find('img');
  }

  update(isForced) {
    if (!isForced && !this.isGlobalUpdate) {
      return;
    }

    this._computeSizes();
    this._initializeContent();
  }

  destroy() {
  }

  _initializeContent() {
    if (this.isPlaceholder) {
      this.root.classList.add('is-placeholder');
    } else if (this.$images.length === 1) {
      this._initializeImage();
    } else {
      this._initializeWallOrSwiper();
    }
  }

  _initializeWallOrSwiper() {
    if (this.wall) {
      this.wall.destroy();
      this.wall = null;
    }
    if (this.swiper) {
      this.swiper.destroy();
      this.swiper = null;
    }

    this.wall = this._buildWall();

    if (!this.wall.images.length) {
      this._setPlaceholder();
    } else if (this.width < this.areaWidth && this.isAlignCover) {
      this._scaleWall(this.wall, this.areaWidth);
    } else if (this.wall.images.length > 1) {
      this._buildSwiper();
    }
  }

  _initializeImage() {
    const image = this.$images[0];
    const imageWidth = image.naturalWidth;
    const imageHeight = this.isVideoShrinked ? image.naturalHeight * 0.744047619 : image.naturalHeight;

    const imageRatio = imageWidth / imageHeight;
    const areaRatio = this.areaWidth / this.areaHeight;

    console.log(imageWidth, imageHeight, imageRatio)

    const isVertical = imageRatio < areaRatio;
    const isHorizontal = imageRatio > areaRatio;

    if (isVertical) {
      if (this.isAlignCover) {
        this._alignVertical(imageRatio);
      } else {
        this.$images.css('height', this.areaHeight);
      }
    }

    if (isHorizontal) {
      if (this.isAlignCover) {
        this._alignHorizontal(imageRatio);
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

  _alignVertical(imageRatio) {
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

  _alignHorizontal(imageRatio) {
    const scaledImageWidth = this.areaHeight * imageRatio;
    const scaleRatio = this.areaWidth / scaledImageWidth;
    const visiblePercent = scaleRatio * 100;

    const marginLeftPercent = ((100 - visiblePercent) / 2 / scaleRatio).round(2);

    if (!this.isVideo) {
      this.$links.css('margin-left', marginLeftPercent > 0 ? `-${marginLeftPercent}%` : '');
    }
    this.$images.css('height', this.areaHeight);
  }

  _computeSizes() {
    // this.$node.removeAttr('style');
    // await delay();

    const { width } = this;
    let height;

    if (this.desiredHeight !== 0) {
      height = this.desiredHeight;
    } else {
      height = (width / RATIO).floor();
    }

    this.areaWidth = width;
    this.areaHeight = height;

    this.$root.css('max-height', this.areaHeight);
  }

  async _imagesLoaded() {
    let hasFailed = false;

    await this.$root.imagesLoaded().catch(() => hasFailed = true);

    if (this.$('.dynamically-replaced').length) {
      // when thumbnail of video is broken, then it is replaced to shikimori custom thumbnail image
      await this.$root.imagesLoaded().catch(() => hasFailed = true);
    }
    return hasFailed;
  }

  _buildWall() {
    return new Wall(this.$root, {
      isOneCluster: true,
      maxWidth: 9999,
      awaitImagesLoaded: false
    });
  }

  _buildSwiper() {
    this.$root.children()
      .addClass('swiper-slide')
      .removeAttr('style')
      .wrapAll('<div class="swiper-wrapper" />');

    this.swiper = new SwiperComponent(this.root, {
      slidesPerView: 'auto',
      spaceBetween: WallCluster.MARGIN,
      a11y: false
    });
  }

  _setPlaceholder(width, height) {
    this.$root
      .css({ width, height })
      .addClass('is-placeholder');
  }

  _scaleWall(wall, width) {
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
