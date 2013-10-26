$('.slide > .images').live('ajax:success cache:success', function(e) {
  fix_danbooru();
  $('.danbooru').show();

  if ('mutex' in arguments.callee) {
    return;
  }
  arguments.callee.mutex = true;

  // на info странице по ajax:success изменяется контент
  $(document.body).on('ajax:success', function() {
    fix_danbooru();
  });

  $(this).gallery();
  var loader = window.loader = new GalleryManager($('.danbooru .images-list'), $('.danbooru .postloader'), 144);
  var suggest = new ImageBoardTagsSuggest(loader);

  $.force_appear();

  _.delay(function() { fix_danbooru(); }, 500);
}).live('ajax:clear', function() {
  $('.danbooru').hide();
});

// успешное автозаполнение
$(document.body).on('completable:callback', '.danbooru-suggest .tag-suggest', function() {
  fix_danbooru();
});

// клик по тегу поиска в заголовке галереи - показ поля для задания тега
$(document.body).on('click', '.images .search-tag', function() {
  _.delay(function() { fix_danbooru(); });
});

// сохранение указанного пользователем тега
$(document.body).on('ajax:success', '.danbooru-suggest form', function() {
  _.delay(function() { fix_danbooru(); });
});

// после инициализации галерии контент поменяется
$(document.body).on('danbooru:init', '.danbooru .images-list', function() {
  $('.danbooru').show();
  fix_danbooru();
});

// на первых двух страницах поиска будем каждый раз пересчитывать высоту контейнера
$(document.body).on('danbooru:page', '.danbooru .images-list', function() {
  fix_danbooru();
});

// после прохождения первой страницы надо убрать костыль, который использовался для выравнивания загрузчика
$(document.body).on('danbooru:page2', '.danbooru .images-list', function() {
  $('.danbooru').removeClass('positioned');
});

// если ничего не найдено, то надо показать блок suggest
$(document.body).on('danbooru:zero', '.danbooru .images-list', function() {
  _.delay(function() { fix_danbooru(); });
});

// костыль на костыле и костылём подпирается
// пересчёт верхней точки отображения галереи
function fix_danbooru() {
  var $menuRight = $('.menu-right');
  var $danbooru = $('.danbooru');

  var slide = $('.slide > .images').parent().height();
  var menuRight = $menuRight.height();
  var viewPort = $('.view-port').height();

  if ($danbooru.height() > menuRight) {
    $danbooru.css({top: slide-viewPort, marginBottom: slide-viewPort});
  } else {
    $danbooru.css({top: slide-viewPort, marginBottom: _.max([slide-viewPort, menuRight-viewPort])});
  }
  $.force_appear();
}
