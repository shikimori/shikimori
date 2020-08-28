$(document).on('turbolinks:load', () => {
  const $menu = $('.menu-toggler');
  if (!$menu.exists()) { return; }

  // переключалка выезжания меню
  $menu.on('click', () => {
    $('.l-page').toggleClass('menu-expanded');
  });
});
