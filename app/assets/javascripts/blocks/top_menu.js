import delay from 'delay';
import { debounce } from 'throttle-debounce';

import GlobalSearch from 'views/search/global';

import showModal from 'helpers/show_modal';
import globalHandler from 'helpers/global_handler';
import { isMobile } from 'helpers/mobile_detect';

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
    const $buttons = $outerNode.children('span');
    const $menu = $outerNode.children('.submenu').show();

    const $items = $menu.children('a')
      .on('focus', ({ currentTarget }) => activate(currentTarget))
      .on('blur', ({ currentTarget }) => deactivate(currentTarget))
      .hover(
        ({ currentTarget }) => $(currentTarget).focus(),
        ({ currentTarget }) => $(currentTarget).blur()
      );

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

    const show = () => {
      $outerNode.addClass('active');
      $('.l-top_menu-v2').addClass('is-submenu');

      globalHandler
        .on('up', moveUp)
        .on('down', moveDown);

      hideMobileSearch();
    };

    const hide = () => {
      $outerNode.removeClass('active');

      // because another menu could already be opened
      if (!$('.l-top_menu-v2 .menu-dropdown.active').length) {
        $('.l-top_menu-v2').removeClass('is-submenu');
      }

      globalHandler
        .off('up', moveUp)
        .off('down', moveDown);
    };
    const isProfile = !!$buttons.children('a').length;

    showModal({
      $modal: $menu,
      $outerNode,
      $trigger: $buttons,
      show,
      hide: async () => {
        hide();

        // need to properly remove focus from menu button when
        // clicked on button when menu is already opened
        await delay();
        $buttons.blur();
      },
      isIgnored: () => !isMobile() && isProfile,
      isHidden: () => !$outerNode.hasClass('active')
    });

    const debouncedHide = debounce(200, () => {
      if (needToClose) {
        hide();
      }
    });
    let needToClose = false;

    $outerNode.hover(
      () => {
        if (isMobile()) { return; }
        needToClose = false;
        show();
      },
      () => {
        if (isMobile()) { return; }
        needToClose = true;
        debouncedHide();
      }
    );
  });

  $('.l-top_menu-v2 .search.mobile').on('click', ({ currentTarget }) => {
    $(currentTarget).toggleClass('active');
    $('.l-top_menu-v2').toggleClass('is-search-mobile');

    if (currentTarget.classList.contains('active')) {
      $search.find('input').focus();
    }
  });
});

$(document).on('turbolinks:before-cache', () => {
  if (search) {
    search.cancel();
    search = undefined;
  }

  $('.l-top_menu-v2').removeClass('is-submenu is-search-mobile');
  $('.l-top_menu-v2 .submenu').prop('style', false);
  $('.l-top_menu-v2 .active').removeClass('active');
});

function hideMobileSearch() {
  const $activeSearch = $('.l-top_menu-v2.is-search-mobile .search.mobile');
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
