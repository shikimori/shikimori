import View from 'views/application/view';

export default class WallImage extends View {
  initialize() {
    this.$image = this.$node.find('img');
    [this.width, this.height] = this._imageSizes();
    [this.originalWidth, this.originalHeight] = Array.from([this.width, this.height]);
    this.ratio = this.width / this.height;

    this.reset();
  }

  reset() {
    this.positioned = false;
    this.left = 0;
    this.top = 0;
    this.width = this.originalWidth;
    this.height = this.originalHeight;
  }

  position(left, top) {
    this.left = left;
    this.top = top;
    this.positioned = true;
  }

  normalize(width, height) {
    if (this.width > width) {
      this.scaleWidth(width);
    }

    if (this.height > height) {
      this.scaleHeight(height);
    }
  }

  apply() {
    this.$image.css({
      width: this.width,
      height: this.height
    });

    this.$node.css({
      top: this.top,
      left: this.left
    });
  }

  destroy() {
    this.$node.removeAttr('style');
    this.$image.removeAttr('style');
  }

  scaleWidth(width) {
    this.height *= width / this.width;
    return this.width = width;
  }

  scaleHeight(height) {
    this.width *= height / this.height;
    return this.height = height;
  }

  scale(percent) {
    this.width *= percent;
    return this.height *= percent;
  }

  weight() {
    return this.ratio.round(1);
    // return (1 / this.ratio).round(1)
  }

  toShikiImage() {
    this.$node.shikiImage();
  }

  _imageSizes() {
    return [
      this.$image[0].naturalWidth * 1.0,
      this.$image[0].naturalHeight * 1.0
    ];
  }
}
