import { loadImages } from '@/helpers/load_image';

import View from '@/views/application/view';

import WallCluster from './cluster';
import WallImage from './image';
import WallVideo from './video';

const MIN_CLUSTER_WEIGHT = 2.5;
const MIN_TWO_CLUSTERS_WEIGHT = 5.8;
const MIN_CLUSTER_HEIGHT = 80;

let lastId = 0;

export default class Wall extends View {
  async initialize(options = {}) {
    this.id = lastId;
    lastId += 1;

    this.isOneCluster = options.isOneCluster;
    this.minClusterHeight = options.isOneCluster !== undefined ?
      options.minClusterHeight :
      MIN_CLUSTER_HEIGHT;
    this.maxWidth = options.maxWidth;
    this.maxHeight = options.maxHeight;

    if (options.awaitImagesLoaded === undefined || options.awaitImagesLoaded) {
      await loadImages(this.node);
    }

    this._prepare();
    this._buildClusters();
    this._mason();
    this._toShikiImages();
  }

  get isTwoClusters() {
    return !this.isOneCluster &&
      this.images.sum(image => image.weight()) > MIN_TWO_CLUSTERS_WEIGHT;
  }

  update() {
  }

  destroy() {
    this.$node.removeAttr('style');
    this.images.forEach(image => image.destroy());
  }

  _prepare() {
    // this.$node.css({
    //   width: '',
    //   height: ''
    // });
    this.$node.removeAttr('style');

    this.maxContainerWidth = parseInt(this.$node.css('width'));

    this.maxHeight = this.maxHeight || parseInt(this.$node.css('max-height'));
    this.maxWidth = this.maxWidth || this.maxContainerWidth;

    const $images = this.$node
      .find('.b-image, .b-video')
      .attr({ rel: `wall-${this.id}` });

    $images.children().removeClass('check-width');

    this.images = $images.toArray().map(node => {
      if (node.classList.contains('b-video')) {
        return new WallVideo($(node));
      }
      return new WallImage($(node));
    });
    // this.images.forEach((image) => console.log(image.weight(), image.node));
  }


  _buildClusters() {
    if (this.isTwoClusters) {
      const imagesCluster1 = [];
      const imagesCluster2 = [];

      this.images.reduce((memo, image) => {
        if (memo > MIN_CLUSTER_WEIGHT) {
          imagesCluster2.push(image);
        } else {
          imagesCluster1.push(image);
        }

        return memo + image.weight();
      }, 0);

      this.cluster_1 = new WallCluster(imagesCluster1, this.maxContainerWidth);
      this.cluster_2 = new WallCluster(imagesCluster2, this.maxContainerWidth);
    } else {
      this.cluster = new WallCluster(this.images, this.maxContainerWidth);
    }
  }

  _mason() {
    let height;
    let width;

    if (this.isTwoClusters) {
      this._masonSecondCluster(false);
      width = [this.cluster_1.width(), this.cluster_2.width()].max();
      height = this.cluster_1.height() + WallCluster.MARGIN + this.cluster_2.height();
    } else {
      this._masonFirstCluster();

      width = this.cluster.width();
      height = this.cluster.height();
    }

    this.$node.css({
      width: ([width, this.maxWidth, this.maxContainerWidth]).min(),
      height: ([height, this.maxHeight]).min()
    });
  }

  _clusterFirstHeight() {
    return [this.maxHeight - this.minClusterHeight, this.minClusterHeight].max();
  }

  _clusterSecondHeight() {
    return [
      ((this.maxHeight - this.cluster_1.height()) + WallCluster.MARGIN).round(),
      this.minClusterHeight
    ].max();
  }

  _masonFirstCluster() {
    return this.cluster.mason(0, this.maxWidth, this.maxHeight);
  }

  _masonSecondCluster(isReposition) {
    this.cluster_1.mason(0, this.maxWidth, this._clusterFirstHeight());
    this.cluster_2.mason(
      this.cluster_1.height() + WallCluster.MARGIN,
      this.maxWidth,
      this._clusterSecondHeight()
    );

    if (isReposition) {
      this.$node.css(
        'max-height',
        this.cluster_2.height() + WallCluster.MARGIN, +this.cluster_1.height()
      );
      return;
    }

    const desiredWidth = (this.maxWidth * 0.95).round();
    if ((this.cluster_2.width() < desiredWidth) || (this.cluster_1.width() < desiredWidth)) {
      this.maxHeight = (this.maxHeight * 1.3).round();
      this.$node.css('max-height', this.maxHeight);
      this.images.forEach(image => image.reset());
      this._masonSecondCluster(true);
    }
  }

  _toShikiImages() {
    this.images.forEach(image => image.toShikiImage());
  }
}
