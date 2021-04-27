import { isMobile } from 'shiki-utils';

let toTopVisible = null;
let $toTop = null;

let scrollDisabled = false;
let scrollBinded = false;

$(document).on('turbolinks:load', () => {
  if (isMobile()) { return; }

  $toTop = $('.b-to-top');
  toTopVisible = null;

  toggle();

  $toTop.on('click', () => {
    hide();
    scrollDisabled = true;
    $('body,html').animate({ scrollTop: 0 }, 50, () => scrollDisabled = false);
  });

  if (!scrollBinded) {
    scrollBinded = true;
    $(window).on('scroll:throttled', toggle);
  }
});

function toggle() {
  if (scrollDisabled) { return; }

  if ($(window).scrollTop() > $('.l-top_menu-v2').height()) {
    show();
  } else {
    hide();
  }
}

function show() {
  if ((toTopVisible === null) || (toTopVisible === false)) {
    $toTop.addClass('active');
    toTopVisible = true;
  }
}

function hide() {
  if ((toTopVisible === null) || (toTopVisible === true)) {
    $toTop.removeClass('active');
    toTopVisible = false;
  }
}
