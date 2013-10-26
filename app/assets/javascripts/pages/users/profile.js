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

// тултип на никнейм
$('h1.aliases').tipsy({
  gravity: 'w',
  html: true
});

// по клику на число просмотренных аниме в профиле-v2 подгружаем соответствующую страницу в слайдах
$('.stat-names a, .klass-caption').live('click', function(e) {
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
