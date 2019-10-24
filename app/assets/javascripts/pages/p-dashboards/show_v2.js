import Swiper from 'swiper';
import { isMobile } from 'helpers/mobile_detect';

let swipers = [];

pageLoad('dashboards_show', () => {
  if (!$('.p-dashboards-show .v2').length) { return; }
  reInitSwipers();
  $(document).on('resize:debounced orientationchange', reInitSwipers);
});

pageUnload('dashboards_show', () => {
  if (!$('.p-dashboards-show .v2').length) { return; }
  destroySwipers();

  $(document).off('resize:debounced orientationchange', reInitSwipers);
});

function reInitSwipers() {
  destroySwipers();

  if (isMobile()) {
    swipers.push(
      new Swiper('.db-updates', {
        slidesPerView: 'auto',
        spaceBetween: 0,
        wrapperClass: 'inner',
        slideClass: 'db-update'
      })
    );
  }
}

function destroySwipers() {
  swipers.forEach(swiper => swiper.destroy());
  swipers = [];
}
