$(document).on('page:load', () => {
  // desktop menu
  const $triggers = $('.l-top_menu-v2 .submenu').parent();
  $triggers.each((_index, node) => {
    const $trigger = $(node);
    const $menu = $trigger.children('.submenu').show();

    const height = $menu.height();
    const borderBottomWidth = parseInt($menu.css('borderBottomWidth'));
    const borderTopWidth = parseInt($menu.css('borderTopWidth'));
    $menu.css({ height: 0, borderTopWidth: 0, borderBottomWidth: 0 });

    $menu
      .showModal({
        trigger: $trigger,
        show: () => {
          $menu.css({ height, borderTopWidth, borderBottomWidth });
          $trigger.addClass('active');
          $('.l-top_menu-v2').addClass('is-submenu');
        },
        hide: () => {
          $menu.css({ height: 0, borderTopWidth: 0, borderBottomWidth: 0 });
          $trigger.removeClass('active');
          $('.l-top_menu-v2').removeClass('is-submenu');
        }
      });

    // return $trigger.hoverDelayed(() =>
    //   $menu.css({
    //     height,
    //     borderBottomWidth
    //   }),
    // () =>
    //   $menu.css({
    //     height: 0,
    //     borderBottomWidth: 0
    //   }),
    // 0, $menu.data('duration') || 150);
  });

//   // mobile menu
//   $('.l-top_menu-v2 .top_menu-toggler').click(function () {
//     if (!this.classList.contains('active') && $('.mobile-search-toggler').hasClass('active')) {
//       $('.mobile-search-toggler').click();
//     }

//     this.classList.toggle('active');

//     return $('.l-top_menu-v2 .menu')
//       .toggleClass('active')
//       .siblings()
//       .removeClass('active');
//   });

//   $('.l-top_menu-v2 .search-toggler').click(function () {
//     if (!this.classList.contains('active') && $('.mobile-menu-toggler').hasClass('active')) {
//       $('.mobile-menu-toggler').click();
//     }

//     this.classList.toggle('active');

//     $('.l-top_menu-v2 .menu-search')
//       .toggleClass('active')
//       .siblings()
//       .removeClass('active');

//     return $('.b-main_search input').focus();
//   });

//   $('.submenu-activator').on('click', function () {
//     return $(this).prev().click();
//   });

//   return $('.submenu-toggler').on('click', function () {
//     $(this).toggleClass('active');
//     return $(this).siblings('.submenu').toggleClass('active');
//   });
});
