import WallImage from './image';

const HEIGHT_RATIO = {
  other: 1.0,
  shrinked: 0.748
};

export default class WallVideo extends WallImage {
  initialize() {
    this.is_shrinked = this.$node.hasClass('shrinked');
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

  _imageSizes() {
    return [
      this.$image[0].naturalWidth * 1.0,
      this.$image[0].naturalHeight * 1.0 * this._heightRatio()
    ];
  }

  _heightRatio() {
    return HEIGHT_RATIO[this.is_shrinked ? 'shrinked' : 'other'];
  }

  _toShikiImage() {}
}
