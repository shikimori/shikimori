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
        },
        hide: () => {
          $menu.css({ height: 0, borderTopWidth: 0, borderBottomWidth: 0 });
          $trigger.removeClass('active');
          $('.l-top_menu-v2').removeClass('is-submenu');
        }
      });
  });
});

$(document).on('turbolinks:before-cache', () => {
  $('.l-top_menu-v2').removeClass('is-submenu');
  $('.l-top_menu-v2 .submenu').prop('style', false);
});
