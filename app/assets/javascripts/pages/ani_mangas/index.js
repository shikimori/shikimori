function init() {
  var type = $('.anime-params-controls').length > 0 ? 'anime' : 'manga';
  var base_path = '/'+type+'s';
  if (location.pathname.match(/recommendations/)) {
    base_path = _(location.pathname.split('/')).first(5).join('/');
    type = 'recommendation';
  }
  var params = new AniMangaParamsParser(base_path, location.href, function(data) {
    History.pushState({timestamp: Date.now()}, null, data);
  });

  function load_page() {
    url = location.href;

    if (url != params.last_compiled) {
      params.parse(url);
    }

    return do_ajax.call(this, url, null, true);
  }

  // history
  History.Adapter.bind(window, 'statechange', load_page);
  pending_load(load_page);
  process_current_dom();
}

function pending_load(load_page) {
  var $pending = $('p.pending');
  if ($pending.length) {
    AjaxCacher.clear(location.href);
    _.delay(function() {
      load_page(location.href).success(function() {
        pending_load(load_page);
      });
    }, 5000);
  } else {
    $('.pending-loaded').show()
  }
}

// активация тултипов для элементов
function pagination_success() {
  $('.uninitialized-tooltip', Controls.$ajax).tooltip(ANIME_TOOLTIP_OPTIONS).removeClass('uninitialized-tooltip');

  Controls.$pagination.toggle(Controls.$link_next.attr('href') != Controls.$link_prev.attr('href'));

  // delay т.к. позже ещё другие колбеки должны отработать, которые поставят pending_requerst=false в ajax.js
  _.delay(function() {
    $.force_appear();
  });
}

$(function() {
  if ($('.menu-left.loaded').length) {
    init();
  }

  window.Controls = {}
  // для более быстрого обращения к узлам
  Controls.$ajax = $('#ajax');
  Controls.$pagination = $('.pagination');
  Controls.$link_current = Controls.$pagination.find('.link-current');
  Controls.$link_next = Controls.$pagination.find('.link-next');
  Controls.$link_prev = Controls.$pagination.find('.link-prev');
  Controls.$link_first = Controls.$pagination.find('.link-first');
  Controls.$link_last = Controls.$pagination.find('.link-last');
  Controls.$link_total = Controls.$pagination.find('.link-total');
  Controls.$link_title = Controls.$pagination.find('.link-title');

  pagination_success();
  Controls.$ajax.on('pagination:success', pagination_success);

  window.EntriesPerPage = $('.animes').data('entries-per-page');
  window.EntriesPerPageDefault = 12.0;
});
// загрузка левого меню
$('.postloaded').live('ajax:success', init);

// загрузка следующей страницы при прокрутке вниз
$('.b-postloader').live('postloader:trigger', function() {
  var $link = Controls.$link_next.first();
  var url = $link.attr('href').replace(/http:\/\/.*?(?=\/)/, '');

  var pages_after_cleanup = 2 * (EntriesPerPageDefault / EntriesPerPage);
  var pages_limit = 26 * (EntriesPerPageDefault / EntriesPerPage);

  var pages = Controls.$link_current.first().html().split('-');

  // после pages_limit загруженных страниц удаляем часть контента сверху (слишком много контента на странице оказывается и начинает тормозить)
  if (pages.length > 1 && parseInt(pages[1]) - parseInt(pages[0]) >= pages_limit) {
    $(this).hide();
    return;
    var next_page = parseInt(url.match(/\d+$/)[0]);
    var current_page = next_page - pages_after_cleanup;
    var url_wo_page = url.replace(/\d+$/, '');

    var $entries = Controls.$ajax.children('.entry-block');
    $entries.slice(0, $entries.length - EntriesPerPage * pages_after_cleanup).remove();

    Controls.$link_current.html(next_page - pages_after_cleanup);

    Controls.$link_prev.removeClass('disabled')
                       .attr('href', url_wo_page + String(current_page - 1))
                       .attr('action', url_wo_page + String(current_page - 1));
    Controls.$link_first.removeClass('disabled')
                        .attr('href', url_wo_page + String(1))
                        .attr('action', url_wo_page + String(1));
  }

  do_ajax.call($link, url, $(this));
});

$('.pagination .link').live('click', function() {
  if ($(this).hasClass('disabled')) {
    return false;
  }
  if ($(window).scrollTop() > 400) {
    $.scrollTo('.head');
  }
  History.pushState({timestamp: Date.now()}, null, this.href);
  return false;
});
