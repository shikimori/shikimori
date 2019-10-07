import ShikiView from 'views/application/shiki_view';
import Swiper from 'swiper';

export default class ShikiSwiper extends ShikiView {
  async initialize() {
    await this.$root.imagesLoaded();

    this.$root.children()
      .addClass('swiper-slide')
      .wrapAll('<div class="swiper-wrapper" />');

    new Swiper(this.root, {
      slidesPerView: 'auto',
      spaceBetween: 20
    });
  }
}
