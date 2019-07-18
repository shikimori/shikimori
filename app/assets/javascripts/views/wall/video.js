import WallImage from './image';

// const HEIGHT_RATIO = {
//   other: 1.0,
//   vk: 0.75417
// };

export default class WallVideo extends WallImage {
  // initialize() {
  //   this.is_vk = this.$node.hasClass('vk');
  //   super.initialize();
  // }

  // apply() {
  //   this.$image.css({
  //     width: this.width,
  //     height: this.height
  //   });

  //   this.$node.css({
  //     top: this.top,
  //     left: this.left,
  //     width: this.width,
  //     height: this.height
  //   });
  // }

  // _imageSizes() {
  //   return [
  //     this.$image[0].naturalWidth * 1.0,
  //     this.$image[0].naturalHeight * 1.0 * this._heightRatio()
  //   ];
  // }

  // _heightRatio() {
  //   return HEIGHT_RATIO[this.is_vk ? 'vk' : 'other'];
  // }

  _toShikiImage() {}
}
