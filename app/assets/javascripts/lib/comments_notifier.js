// уведомлялка о новых комментариях
// назначение класса - смотреть на странице новые комментаы и отображать информацию об этом
function CommentsNotifier() {
  // дом элемент нотификатора
  var $notifier = $('<div class="b-comments-notifier" style="display: none;" alt="Число непрочитанных комментариев"></div>');
  var $window = $(window);
  $(document.body).append($notifier);
  // текущее значение счётчика
  var current_count = 0;

  // пересчёт значения счётчика
  var refresh = function(e) {
    _.delay(function() {
      var $comment_new = $('.comment-new');
      var $faye_loader = $('.faye-loader');

      var count = $comment_new.length;

      $faye_loader.each(function() {
        count += $(this).data('ids').length;
      });
      set_count(count);
    });
  }
  // установление значение счётчика
  var set_count = function(count) {
    current_count = count;
    if (count > 0) {
      $notifier.show()
               .html(count);
    } else {
      $notifier.hide();
    }
  }
  // по клику на нотификатор происходит прокрутка до нового элемента
  $notifier.on('click', function() {
    var $first_unread = $('.comment-new,.faye-loader').first();
    $.scrollTo($first_unread, 'easeInOutCirc');
  });
  // при прочтении комментов, декрементим счётчик
  $window.on('appear', function(e, $appeared, by_click) {
    //var $nodes = ($appeared || $(this)).not('.postloader').not(function() { return $(this).data('disabled') });
    var $nodes = $(e.target)
        .not('.postloader')
        .not(function() { return $(this).data('disabled') });

    set_count(current_count - $nodes.length);
  });
  // при добавление блока о новом комментарии/топике делаем инкремент
  $window.on('faye:added', function(e, $appeared, by_click) {
    set_count(current_count+1);
  });
  // при загрузке контента fayer-loader'ом - полный пересчёт счётчика
  $window.on('faye:loaded', refresh);
  // при загрузке контента fayer-loader'ом - полный пересчёт счётчика
  $window.on('ajax:success', refresh);
  // при загрузке контента postloader'ом - полный пересчёт счётчика
  $window.on('postloader:success', refresh);

  // смещение вверх-вниз блока уведомлялки
  var scroll_lock = false;
  var max_top = 31;
  var scroll = $window.scrollTop();
  var block_top = 0;

  $window.scroll(function(e) {
    scroll = $window.scrollTop();
    if (scroll <= max_top) {
      move();
    } else if (scroll > max_top && block_top != 0) {
      move();
    }
    //if (scroll_lock) {
      //return;
    //}
    //scroll_lock = true;

    //_.delay(move, 2000);
  });
  var move = function() {
    scroll_lock = false;
    block_top = _.max([0, max_top-scroll]);
    $notifier.css('top', block_top+'px');
  };
  move();

  refresh();

  return {
    refresh: refresh
  }
}
