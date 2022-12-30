import delay from 'delay';
import { debounce } from 'throttle-debounce';

import GlobalSearch from '@/views/search/global';

import showModal from '@/utils/show_modal';
import globalHandler from '@/utils/global_handler';
import { isMobile, isTablet } from 'shiki-utils';

$(document).on('turbolinks:load', () => {
  const $search = $('.l-top_menu-v2 .global-search');

  if ($search.length) {
    window.globalSearch = new GlobalSearch(
      $search,
      { showMobileSearch, hideMobileSearch }
    );
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
      // do not execute show logic multiple times
      if ($outerNode.hasClass('active')) { return; }

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
        if (isMobile() || isTablet()) { return; }
        needToClose = false;
        show();
      },
      () => {
        if (isMobile() || isTablet()) { return; }
        needToClose = true;
        debouncedHide();
      }
    );
  });

  $('.l-top_menu-v2 .search.mobile').on('click', _e => {
    if ($('.l-top_menu-v2').hasClass('is-search-mobile')) {
      hideMobileSearch();
    } else {
      showMobileSearch();
      $search.find('input').focus();
    }
  });
});

$(document).on('turbolinks:before-cache', () => {
  if (window.globalSearch) {
    window.globalSearch.cancel();
    delete window.globalSearch;
  }

  $('.l-top_menu-v2').removeClass('is-submenu is-search-mobile');
  $('.l-top_menu-v2 .submenu').removeAttr('style');
  $('.l-top_menu-v2 .active').removeClass('active');
});

function showMobileSearch() {
  $('.l-top_menu-v2.is-search-mobile .search.mobile').addClass('active');
  $('.l-top_menu-v2').addClass('is-search-mobile');
}

function hideMobileSearch() {
  $('.l-top_menu-v2.is-search-mobile .search.mobile').removeClass('active');
  $('.l-top_menu-v2').removeClass('is-search-mobile');

  if (window.globalSearch.isActive) {
    window.globalSearch.cancel();
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
