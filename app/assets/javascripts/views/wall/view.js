import View from 'views/application/view';

import WallCluster from './cluster';
import WallImage from './image';
import WallVideo from './video';

const MIN_CLUSTER_WEIGHT = 2.5;
const MIN_TWO_CLUSTERS_WEIGHT = 5.8;
const MIN_CLUSTER_HEIGHT = 80;

let lastId = 0;

export default class Wall extends View {
  async initialize() {
    this.id = lastId;
    lastId += 1;

    this.$inner = this.$node.children('.inner');

    await this.$root.imagesLoaded();

    this._prepare();
    this._buildClusters();
    this._mason();
  }

  _prepare() {
    this.$node.css({
      width: '',
      height: ''
    });

    this.maxHeight = parseInt(this.$node.css('max-height'));
    this.maxWidth = parseInt(this.$node.css('width'));

    const $images = this.$inner
      .children('a, .b-video')
      .attr({ rel: `wall-${this.id}` })
      .css({ width: '', height: '' });

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
    if (this._isTwoClusters()) {
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

      this.cluster_1 = new WallCluster(imagesCluster1);
      this.cluster_2 = new WallCluster(imagesCluster2);
    }
    this.cluster = new WallCluster(this.images);
  }

  _mason() {
    let height;
    let width;

    if (this._isTwoClusters()) {
      this._masonSecondCluster(false);
      width = [this.cluster_1.width(), this.cluster_2.width()].max();
      height = this.cluster_1.height() + WallCluster.MARGIN + this.cluster_2.height();
    } else {
      this._masonFirstCluster();
      width = this.cluster.width();
      height = this.cluster.height();
    }

    this.$node.css({
      width: ([width, this.maxWidth]).min(),
      height: ([height, this.maxHeight]).min()
    });
  }

  _isTwoClusters() {
    return this.images.sum(image => image.weight()) > MIN_TWO_CLUSTERS_WEIGHT;
  }

  _clusterFirstHeight() {
    return [this.maxHeight - MIN_CLUSTER_HEIGHT, MIN_CLUSTER_HEIGHT].max();
  }

  _clusterSecondHeight() {
    return [
      ((this.maxHeight - this.cluster_1.height()) + WallCluster.MARGIN).round(),
      MIN_CLUSTER_HEIGHT
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
}
