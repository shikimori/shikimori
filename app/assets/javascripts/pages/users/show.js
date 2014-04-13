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
  var fix_russian = function(text) {
    var splitted = text.split('/');
    if (splitted.length > 1) {
      splitted[1] = encodeURIComponent(splitted[1]).replace('%2B', '+');
    }
    return splitted.join('/');
  };
  // history
  History.Adapter.bind(window, 'statechange', function() {
    url = location.href.replace(/http:\/\/.*?\//, '/');
    $(".slider-control a[href$='"+url+"'],.slider-control a[href$='"+fix_russian(url)+"']")
      .parent()
      .trigger('slider:click');
  });
  $(window).trigger('statechange');

  if ($('.messages .selected').length === 0) {
    $('.messages .collapse').trigger('click', true);
  }

  // отображалка новых комментариев
  if (IS_LOGGED_IN) {
    window.comments_notifier = new CommentsNotifier();
  }
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
