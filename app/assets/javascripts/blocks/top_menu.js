import showModal from 'helpers/show_modal';
import GlobalSearch from 'views/search/global';

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

    // let height = null;
    // let borderBottomWidth = null;
    // let borderTopWidth = null;

    // $outerNode.one('mouseover', () => {
    //   height = $menu.height();
    //   borderBottomWidth = parseInt($menu.css('borderBottomWidth'));
    //   borderTopWidth = parseInt($menu.css('borderTopWidth'));

    //   $menu.css({ height: 0, borderTopWidth: 0, borderBottomWidth: 0 });
    // });

    showModal({
      $modal: $menu,
      $outerNode,
      $trigger: $buttons,
      show: () => {
        // console.log('show');
        // $menu.css({ height, borderTopWidth, borderBottomWidth });

        $outerNode.addClass('active');
        $('.l-top_menu-v2').addClass('is-submenu');

        hideMobileSearch();
      },
      hide: () => {
        // console.log('hide');
        // $menu.css({ height: 0, borderTopWidth: 0, borderBottomWidth: 0 });

        $outerNode.removeClass('active');
        $('.l-top_menu-v2').removeClass('is-submenu');
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
  $('.l-top_menu-v2').removeClass('is-submenu');
  $('.l-top_menu-v2 .submenu').prop('style', false);
});

function hideMobileSearch() {
  const $activeSearch = $('.l-top_menu-v2.is-mobile-search .search.mobile');
  if ($activeSearch.length) {
    $activeSearch.click();
    search.cancel();
  }
}
