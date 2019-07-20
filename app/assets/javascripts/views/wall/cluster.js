export default class WallCluster {
  static initClass() {
    this.MARGIN = 4;
  }

  constructor(images) {
    this.images = images;
  }

  mason(top, maxWidth, maxHeight) {
    this.top = top;
    this.maxWidth = maxWidth;
    this.maxHeight = maxHeight;

    this.images.forEach(image => image.normalize(this.maxWidth, this.maxHeight));
    this.images.forEach(image => this._put(image));
    this.images.forEach(image => image.apply());
  }

  width() {
    return (this.images.map(v => v.left + v.width)).max() || 0;
  }

  height() {
    return (this.images.map(v => v.top + v.height)).max() || 0;
  }

  _positioned() {
    return this.images.filter(v => v.positioned);
  }

  _put(image) {
    let left = (this._positioned().map(v => v.left + v.width)).max();

    if (left) {
      left += WallCluster.MARGIN;
    } else {
      left = 0;
    }

    image.position(left, this.top);

    this._flatten();
    this._scale();
  }

  _flatten() {
    const images = this._positioned();
    if (images.length === 1) { return; }

    const heights = images.map(v => v.height);
    const minHeight = heights.min();

    if (minHeight !== heights.max()) {
      images.forEach(image => {
        image.scaleHeight(minHeight);
        image.positioned = false;
      });

      images.forEach(image => this._put(image));
    }
  }

  _scale() {
    const images = this._positioned();
    const currentWidth = images.reduce((memo, v) => memo + v.width + WallCluster.MARGIN, 0.0);

    if (currentWidth > this.maxWidth) {
      images.forEach(image => {
        image.scale(this.maxWidth / currentWidth);
        image.positioned = false;
      });

      images.forEach(image => this._put(image));
    }
  }
}
WallCluster.initClass();
