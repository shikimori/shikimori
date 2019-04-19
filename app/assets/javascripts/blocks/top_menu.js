$(document).on('turbolinks:load', () => {
  // desktop menu
  const $triggers = $('.l-top_menu-v2 .submenu').parent();
  $triggers.each((_index, node) => {
    const $trigger = $(node);
    const $menu = $trigger.children('.submenu').show();

    let height = null;
    let borderBottomWidth = null;
    let borderTopWidth = null;

    $trigger.one('mouseover', () => {
      height = $menu.height();
      borderBottomWidth = parseInt($menu.css('borderBottomWidth'));
      borderTopWidth = parseInt($menu.css('borderTopWidth'));
      $menu.css({ height: 0, borderTopWidth: 0, borderBottomWidth: 0 });
    });

    $menu
      .showModal({
        trigger: $trigger,
        show: async () => {
          $menu.css({ height, borderTopWidth, borderBottomWidth });
          $trigger.addClass('active');
          $('.l-top_menu-v2').addClass('is-submenu');

          hideSearch();
        },
        hide: () => {
          $menu.css({ height: 0, borderTopWidth: 0, borderBottomWidth: 0 });
          $trigger.removeClass('active');
          $('.l-top_menu-v2').removeClass('is-submenu');
        }
      });
  });


  $('.l-top_menu-v2 .search.mobile').on('click', ({ currentTarget }) => {
    $(currentTarget).toggleClass('active');
    $('.l-top_menu-v2').toggleClass('is-mobile-search');

    if (currentTarget.classList.contains('active')) {
      $('.l-top_menu-v2 .global-search input').focus();
    }
  });

  $('.l-top_menu-v2 .global-search .clear').on('click', () => {
    hideSearch();
  });
});

$(document).on('turbolinks:before-cache', () => {
  $('.l-top_menu-v2').removeClass('is-submenu');
  $('.l-top_menu-v2 .submenu').prop('style', false);
});

function hideSearch() {
  $('.l-top_menu-v2.is-mobile-search .search.mobile').click();
}
