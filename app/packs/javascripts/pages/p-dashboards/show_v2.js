import { isPhone, isMobile } from 'shiki-utils';

let swipers = [];

pageLoad('dashboards_show', () => {
  if (!$('.p-dashboards-show .v2').length) { return; }
  reInitSwipers();
  $(document).on('resize:debounced orientationchange', reInitSwipers);

  const createTopic = document.querySelector('.create-topic');
  if (createTopic) {
    createTopic.href = createTopic.href.replace('USER_ID', window.SHIKI_USER.id);
  }
});

pageUnload('dashboards_show', () => {
  if (!$('.p-dashboards-show .v2').length) { return; }
  destroySwipers();
  $(document).off('resize:debounced orientationchange', reInitSwipers);
});

async function reInitSwipers() {
  destroySwipers();

  if (!isMobile() && !isPhone()) { return; }

  const { default: Swiper } =
    await import(/* webpackChunkName: "swiper" */ '@/vendor/async/swiper');

  if (isMobile()) {
    swipers.push(
      new Swiper('.fc-ongoings', {
        slidesPerView: 'auto',
        slidesPerColumn: 1,
        spaceBetween: 0,
        wrapperClass: 'inner',
        slideClass: 'b-catalog_entry',
        navigation: {
          nextEl: '.mobile-slider-next',
          prevEl: '.mobile-slider-prev'
        }
      })
    );

    swipers.push(
      new Swiper('.db-updates', {
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
  }

  if (isPhone()) {
    swipers.push(
      new Swiper('.content-updates', {
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

    swipers.push(
      new Swiper('.hot-topics', {
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
