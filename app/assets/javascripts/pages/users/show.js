var fix_russian = function(text) {
  var splitted = text.split('/');
  if (splitted.length > 1) {
    splitted[1] = encodeURIComponent(splitted[1]).replace('%2B', '+');
  }
  return splitted.join('/');
};

// выравнивание высоту истории с инфой пользователя слева
$(window).on('load', function() {
  var $history = $('.user-history');
  var $info = $('.profile .left-block');
  if ($history.height() > $info.height()) {
    var max_height = $info.offset().top + $info.height();
    var $entries = $history.find('li');

    for (var i = $entries.length - 1; i >= 0; i--) {
      var $entry = $($entries[i]);

      if ($entry.offset().top > max_height) {
        $entry.hide();
      }
    }
  }
});

$(function() {
  // slides
  $('.slider-control').live('click', function(e) {
    // we should ignore middle button click
    if (in_new_tab(e)) {
      return;
    }
    History.pushState(null, null, $(this).children('a').attr('href').replace(/http:\/\/.*?\//, '/'));
    return false;
  });
  $('.user-content-slider').makeSliderable({
    $controls: $('.slider-control'),
    history: true,
    remote_load: true,
    easing: 'easeInOutBack',
    onslide: function($control) {
      $('.slider-control').removeClass('selected');
      $control.addClass('selected');
    }
  });
  // отображалка новых комментариев
  if (IS_LOGGED_IN) {
    window.comments_notifier = new CommentsNotifier();
  }

  // history
  History.Adapter.bind(window, 'statechange', function() {
    var url = location.href.replace(/http:\/\/.*?\//, '/');
    $(".slider-control a[href$='"+url+"'],.slider-control a[href$='"+fix_russian(url)+"']")
      .parent()
      .trigger('slider:click');
  });
  // чтобы колбеки активировались
  $('.slide > .selected').trigger('cache:success');
});

// добавление/удаление из друзей
$('.friend-action').live('ajax:success', function() {
  $(this)
    .hide()
      .siblings('.friend-action')
      .show();
});
// добавление/удаление в игнор
$('.ignore-action').live('ajax:success', function() {
  $(this)
    .hide()
      .siblings('.ignore-action')
      .show();
});

// тултип на никнейм
$('h1.aliases').tipsy({
  gravity: 'w',
  html: true
});

// по клику на число просмотренных аниме в профиле-v2 подгружаем соответствующую страницу в слайдах
$('.stat-names a, .klass-caption, .stat-categories a').live('click', function(e) {
  if (in_new_tab(e)) {
    return;
  }
  var $this = $(this);
  var target_url = $this.attr('href');

  var $user_menu = $('.user-menu');
  var $control = $user_menu.find("a[href='"+target_url+"']");
  var is_anime = $this.attr('href').match(/anime/);
  if (!$control.length) {
    $user_menu.append('<li class="hidden slider-control slider-control-'+(is_anime ? 'anime' : 'manga')+'list"><a href="'+target_url+'">'+$this.html()+'</a></li>');
    $control = $user_menu.find("a[href='"+target_url+"']");
  }
  var $content_placeholder = $('.slide > .'+(is_anime ? 'anime' : 'manga')+'list');
  if ($content_placeholder.data('loaded-url') != target_url) {
    $content_placeholder.empty();
  }
  $content_placeholder.data('loaded-url', target_url);
  $control.trigger('click');

  // подсвечиваем нужный пункт в меню с задержкой
  //_.delay(function() {
    //$user_menu.find("a[href='"+$this.attr('href').replace(/(anime|manga).*/, '$1')+"']").parent().addClass('selected');
  //}, 500);

  return false;
});
