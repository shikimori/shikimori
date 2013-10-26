$(function() {
  var type = $('.anime-params-controls').length > 0 ? 'anime' : 'manga';
  var params = new AniMangaParamsParser(location.pathname.replace(/(\/vs\/[^\/]*)\/.*/, '$1'), function(data) {
    $.history.load(data);
  });

  // history
  $.history.init(load_page);

  function load_page(url) {
    if (url == "" && !('flag' in arguments.callee)) {
      params.parse(location.pathname.replace(/(\/vs\/[^\/]*)$/, '$1/order-by/ranked'));
      arguments.callee.flag = true;
      return;
    } else if (url == undefined || url == "") {
      params.parse(location.pathname);
      url = location.pathname;
    } else if (url != params.last_compiled) {
      params.parse(url);
    }

    do_ajax.call(this, url);
  }

  apply_list_handlers();

  $('.ajax').on('ajax:success', apply_list_handlers);
});

// обработчики для списка
function apply_list_handlers() {
  $('.default-table tr.selectable').tooltip($.extend($.extend({}, tooltip_options), {
    offset: [3, -520],
    position: 'bottom right',
    opacity: 1,
    onBeforeShow: null,
    onBeforeHide: null,
    moved: true
  }));
}
