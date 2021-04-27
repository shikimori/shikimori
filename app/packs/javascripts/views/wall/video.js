import WallImage from './image';

const HEIGHT_RATIO = {
  default: 1.0,
  'shrinked-1_3': 0.744,
  'shrinked-1_5': 0.8
};

export default class WallVideo extends WallImage {
  initialize() {
    this.ratioKey = this.node.className.match(/shrinked-\d_\d/)?.[0] || 'default';
    super.initialize();
  }

  apply() {
    this.$image.css({
      width: this.width
      // height: this.height
    });

    this.$node.css({
      top: this.top,
      left: this.left,
      width: this.width,
      height: this.height
    });
  }

  toShikiImage() {}

  _imageSizes() {
    return [
      this.$image[0].naturalWidth * 1.0,
      this.$image[0].naturalHeight * 1.0 * this._heightRatio()
    ];
  }

  _heightRatio() {
    return HEIGHT_RATIO[this.ratioKey];
  }
}
