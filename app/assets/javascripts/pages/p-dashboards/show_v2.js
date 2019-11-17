import Swiper from 'swiper';
import { isMobile } from 'helpers/mobile_detect';

let swipers = [];
window.z = swipers;

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
      new Swiper('.fc-db-updates', {
        slidesPerView: 'auto',
        slidesPerColumn: 2,
        spaceBetween: 30,
        wrapperClass: 'inner',
        slideClass: 'db-update',
        navigation: {
          nextEl: '.mobile-slider-next',
          prevEl: '.mobile-slider-prev'
        }
      })
    );

    swipers.push(
      new Swiper('.fc-content-updates', {
        slidesPerView: 'auto',
        slidesPerColumn: 3,
        spaceBetween: 30,
        wrapperClass: 'inner',
        slideClass: 'b-news_line-topic',
        navigation: {
          nextEl: '.mobile-slider-next',
          prevEl: '.mobile-slider-prev'
        }
      })
    );
  }
}

function destroySwipers() {
  swipers.forEach(swiper => swiper.destroy());
  swipers = [];
}
