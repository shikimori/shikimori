import delay from 'delay';

import GlobalSearch from 'views/search/global';

import showModal from 'helpers/show_modal';
import globalHandler from 'helpers/global_handler';

let search;

$(document).on('turbolinks:load', () => {
  const $search = $('.l-top_menu-v2 .global-search');

  if ($search.length) {
    search = new GlobalSearch($search);
  }
  $search.find('.clear').on('click', hideMobileSearch);

  // desktop menu
  $('.l-top_menu-v2 .menu-dropdown').each((_, node) => {
    const $outerNode = $(node);
    const $buttons = $outerNode.children('button');
    const $menu = $outerNode.children('.submenu').show();

    const $items = $menu.children('a')
      .on('focus', ({ currentTarget }) => activate(currentTarget))
      .on('blur', ({ currentTarget }) => deactivate(currentTarget))
      .hover(
        ({ currentTarget }) => $(currentTarget).focus(),
        ({ currentTarget }) => $(currentTarget).blur()
      );

    let height = null;
    let borderBottomWidth = null;
    let borderTopWidth = null;

    $outerNode.one('mouseover', () => {
      height = $menu.height();
      borderBottomWidth = parseInt($menu.css('borderBottomWidth'));
      borderTopWidth = parseInt($menu.css('borderTopWidth'));

      $menu.css({ height: 0, borderTopWidth: 0, borderBottomWidth: 0 });
    });

    const moveUp = e => {
      e.preventDefault();
      e.stopImmediatePropagation();

      const $activeItem = $items.filter('.active');

      if (!$activeItem.length) { return; }

      $($items[$items.index($activeItem) - 1]).focus();
    };

    const moveDown = e => {
      e.preventDefault();
      e.stopImmediatePropagation();

      const $activeItem = $items.filter('.active');

      if (!$activeItem.length) {
        $items.first().focus();
        return;
      }

      $($items[$items.index($activeItem) + 1]).focus();
    };

    showModal({
      $modal: $menu,
      $outerNode,
      $trigger: $buttons,
      show: () => {
        $menu.css({ height, borderTopWidth, borderBottomWidth });

        $outerNode.addClass('active');
        $('.l-top_menu-v2').addClass('is-submenu');

        globalHandler
          .on('up', moveUp)
          .on('down', moveDown);

        hideMobileSearch();
      },
      hide: async () => {
        $menu.css({ height: 0, borderTopWidth: 0, borderBottomWidth: 0 });

        $outerNode.removeClass('active');
        $('.l-top_menu-v2').removeClass('is-submenu');

        globalHandler
          .off('up', moveUp)
          .off('down', moveDown);

        // need to properly remove focus from menu button when
        // clicked on button when menu is already opened
        await delay();
        $buttons.blur();
      }
    });
  });

  $('.l-top_menu-v2 .search.mobile').on('click', ({ currentTarget }) => {
    $(currentTarget).toggleClass('active');
    $('.l-top_menu-v2').toggleClass('is-mobile-search');

    if (currentTarget.classList.contains('active')) {
      $search.find('input').focus();
    }
  });
});

$(document).on('turbolinks:before-cache', () => {
  $('.l-top_menu-v2').removeClass('is-submenu is-global-search');
  $('.l-top_menu-v2 .submenu').prop('style', false);
  $('.l-top_menu-v2 .active').removeClass('active');
});

function hideMobileSearch() {
  const $activeSearch = $('.l-top_menu-v2.is-mobile-search .search.mobile');
  if ($activeSearch.length) {
    $activeSearch.click();
    search.cancel();
  }
}

function activate(node) {
  node.setAttribute('tabindex', 0);
  node.classList.add('active');
}

function deactivate(node) {
  node.setAttribute('tabindex', -1);
  node.classList.remove('active');
}
