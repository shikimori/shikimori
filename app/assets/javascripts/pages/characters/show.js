$(function() {
  // slides
  $('.slider-control').click(function(e) {
    // we should ignore middle button click
    if (in_new_tab(e)) {
      return;
    }
    History.pushState(null, null, ($(this).children('a').attr('href') || $(this).children('span.link').data('href')).replace(/http:\/\/.*?\//, '/'));
    return false;
  });
  var $controls = $('.slider-control', $('.character-left-menu'));
  $('.entry-content-slider').makeSliderable({
    $controls: $controls,
    history: true,
    remote_load: true,
    easing: 'easeInOutBack',
    onslide: function($control) {
      $controls.removeClass('selected');
      $control.addClass('selected');
    }
  });

  History.Adapter.bind(window, 'statechange', function() {
    url = location.href.replace(/http:\/\/.*?\//, '/');

    var $target;
    $('.slider-control a,.slider-control span.link').each(function(k, v) {
      if (url.indexOf((this.className.indexOf('link') == -1 ? this.href : $(this).data('href')).replace(/http:\/\/.*?(?=\/)/, '')) != -1) {
        $target = $(this).parent();
      }
    });
    var menu_url = ($target.children('a').attr('href') || $target.children('span.link').data('href')).replace(/http:\/\/.*?(?=\/)/, '');
    if (menu_url != url) {
      // в нужном li делается подмена урла, т.к. урл для загрузки страницы будет взят оттуда, а затем после загрузки страницы урл меняется назад
      $target.children().attr('href', url).data('href', url);
      $target.trigger('slider:click');
      $target.children().attr('href', menu_url).data('href', menu_url);
    } else {
      $target.trigger('slider:click');
    }
  });
  // надо вызывать, чтобы сработал хендлер, навешенный на переключение слайда
  $('.slide > .selected').trigger('cache:success');
});

// переход в Обсуждение по клику на комментировать
$('.actions .comment').live('click', function() {
  var editor_selector = '.comments .comments-container > .shiki-editor:first-child';
  if ($('.slide > .comments').hasClass('selected')) {
    $(editor_selector).focus();
  } else {
    $('.slide > .comments').one('ajax:success cache:success', function() {
      _.delay(function() {
        $(editor_selector).focus();
      }, 250);
    });
    $('.slider-control-comments').trigger('click');
  }
});
