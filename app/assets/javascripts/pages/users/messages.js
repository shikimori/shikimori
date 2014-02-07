var $messages_links;
var counts;
$(function() {
  // если есть этот элемент, то при загрузке страницы активна вкладка с новым сообщением
  if ($('#message_body').length) {
    $('.slide .new-message').trigger('ajax:success');
  }

  // число прочитанных сообщений
  counts = {
    inbox: '.slider-control-inbox .unread-count, .userbox .unread-count, .unread-count.inbox',
    news: '.slider-control-news .unread-count, .userbox .unread-count, .unread-count.news',
    notifications: '.slider-control-inbox .unread-count, .userbox .unread-count, .unread-count.notifications'
  }
  // пометка сообщений прочитанными
  //$('.new .appear-marker').appear(mark_read, { force_process: false });
});

// на сообщениях клик на кнопку перехода к настройкам
//$('.to-messages-settings').live('click', function() {
  //$('.slider-control-notifications-settings').trigger('click');
//});

$('.slide .inbox').live('ajax:success', function(e, data) {
  // реинициализация числа просмотренных сообщений
  //for (var type in data.counts) {
    //var $count = $('.slider-control-'+type+' .unread-count').html('('+data.counts[type]+')');
    //if (data.counts[type] > 0) {
      //$count.show();
    //} else {
      //$count.hide();
    //}
  //}
  // принудительный процессинг всех видимых элементов
  //$.force_appear();
}).live('ajax:clear', function(e, data) {
  // очистка контента, чтобы в следующий раз загрузился новый
  if ($.isReady) {
    $(this).append('<div class="clear-marker"></div>');
  }
});

// переключение вкладок сообщений
$('.inbox .b-options-floated a').live('click', function() {
  $('.inbox.slider-control a')
    .attr('href', $(this).attr('href'))
    .trigger('click');
  return false;
});

// при принятии запроса в друзья помечаем сообщение прочитанным
$('a[rel=slider]').live('click', function() {
  $('.slider-control a[href="'+this.href+'"]').trigger('click');
  return false;
});

// при принятии запроса в друзья помечаем сообщение прочитанным
$('.item-request-confirm').live('ajax:success', function() {
  $(this).parent().children('.item-request-reject').trigger('message:mark');
});

// при отклонении запроса в друзья помечаем сообщение прочитанным
$('.item-request-reject').live('click message:mark', function(e) {
  var $marker = $(this).parents('.message-block')
                       .find('.appear-marker');
  $marker.data('disabled', false)
  $marker.trigger('appear', [$marker, true]);

  $(this).parents('.message-block')
         .find('.buttons')
         .hide();
});

// обновление числа прочитанных элементов
$('.inbox .appear-marker').live('appear', function(e, $appeared, by_click) {
  var $nodes = ($appeared || $(this)).not(function() { return $(this).data('disabled') });

  var type = location.href.match(/\/([\w-]+)$/)[1];
  var $nodes_to_count = $nodes.not(function() { return $(this).data('appear-counted') }).parents('.message-block');

  update_counts($nodes_to_count, type, true);
  $nodes.data('appear-counted', true);
});

// обновление числа непрочитанных уведомлений в левом и верхнем меню
function update_counts($messages, type, is_read) {
  $(counts[type]).each(function() {
    var $count = $(this)
    var count = $count.html().match(/\d+/)[0] - (is_read ? $messages.length : -$messages.length);

    if ($count.html().match(/\(/)) {
      $count.html('('+(count)+')');
    } else {
      $count.html(count);
    }
    $count.toggle(!!count)
  });
}
