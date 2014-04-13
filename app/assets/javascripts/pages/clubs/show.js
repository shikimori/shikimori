$(function() {
  // slides
  $('.slider-control').click(function(e) {
    // we should ignore middle button click
    if (in_new_tab(e)) {
      return;
    }
    History.pushState(null, null, $(this).children('a').attr('href').replace(/http:\/\/.*?\//, '/'));
    return false;
  });
  $('.group-content-slider').makeSliderable({
    $controls: $('.slider-control'),
    history: true,
    remote_load: true,
    easing: 'easeInOutBack',
    onslide: function($control) {
      $('.slider-control').removeClass('selected');
      $control.addClass('selected');
    }
  });
  History.Adapter.bind(window, 'statechange', function() {
    $(".slider-control a[href$='"+location.href+"']").parent().trigger('slider:click');
  });
  // надо вызывать, чтобы сработал хендлер, навешенный на переключение слайда
  $('.slide > .selected').trigger('cache:success');

  // показ/скрытие блока с действиями
  if (!$('.actions-list').children().length) {
    $('.actions').hide();
  } else {
    $('.actions').show();
  }
  // отображалка новых комментариев
  if (IS_LOGGED_IN) {
    window.comments_notifier = new CommentsNotifier();
  }

  // надо вызывать, чтобы сработал хендлер, навешенный на переключение слайда
  $('.slide .selected').trigger('cache:success');

  $('.upload-image-container').tipsy({gravity: 's'});
});

// загрузка картинки
$('.upload-image-container input').live('change', function() {
  //if (!$('.slide > .selected .images-container').length) {
    //debugger
    $(this).parents('form').submit();
    //return false;
  //}
});

// вступление в группу
$('.join-group').live('ajax:success', function(e, data, status, xhr) {
  var $member = $(data.member);
  $('.members-list').prepend($member)
  $member.yellowFade();
  //increment_comments_num($('.slider-control-members a .num'));

  $('.actions-list').replaceWith(data.actions);
  if (!$('.actions-list').children().length) {
    $('.actions').hide();
  } else {
    $('.actions').show();
  }
});

// выход из группы
$('.leave-group').live('ajax:success', function(e, data, status, xhr) {
  $('.user-'+data.user+'-block').remove();
  //decrement_comments_num($('.slider-control-members a .num'));

  $('.actions-list').replaceWith(data.actions);
  if (!$('.actions-list').children().length) {
    $('.actions').hide();
  } else {
    $('.actions').show();
  }
});

// приглашение в группу
$('.send-invite-container').live('click', function(e) {
  var $input = $('.send-invite');
  if ($input.hasClass('hidden')) {
    $(this).children().toggleClass('hidden');
    if ($input.attr('value') == '') {
      $input.attr('value', 'укажите имя пользователя');
    }
    $input.focus().select();
  }
});
$('.send-invite').live('keydown', function(e) {
  if (e.keyCode == 27) {
    $(this).parent().children().toggleClass('hidden');
  }
}).live('keypress blur', function(e) {
  var $this = $(this);
  if ((e.which == 13 || e.type == 'focusout') && !$this.hasClass('hidden')) {
    if (this.value != '' && this.value != 'укажите имя пользователя') {
      $this.callRemote();
      return;
    }
    $this.parent().children().toggleClass('hidden');
  }
}).live('ajax:loading', function(e, data) {
  data.ajax.url = data.ajax.url.replace('$nickname', this.value);
}).live('ajax:success', function(e, data) {
  var $this = $(this);
  $this.parent().children().toggleClass('hidden');
  $this.attr('value', '');
}).live('ajax:failure', function() {
  $(this).parent().children().toggleClass('hidden');
});

function group_gallery(node) {
  $(node).gallery();

  var $gallery = $('.images-list', node);
  $gallery.shikiFile({
    progress: $gallery.prev(),
    //input: $('#image_image'),
  })
  .on('upload:success', function(e, response) {
    var $image = $(response.html);
    $('a', $image).fancybox($.galleryOptions);

    $gallery.prepend($image);
            //.masonry('option', { isAnimated: false })
            //.masonry('appended', $image);
  })
  .on('upload:after', function() {
    _.delay(function() {
      $gallery.masonry('option', { isAnimated: true });
      $gallery.masonry('reload');
    }, 100);
  });
}
