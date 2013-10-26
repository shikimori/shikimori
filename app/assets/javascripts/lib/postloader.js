// динамическая подгрузка контента по мере прокрутки страницы
$('.postloader').appear();
$('.postloader').live('click appear', function() {
  var $postloader = $(this);
  if ($postloader.data('locked')) {
    return;
  }
  var new_postloader = $postloader.hasClass('new');

  // для нового лоадера никаких манипуляций делать не нужно
  if (new_postloader) {
    $postloader.html('<div class="ajax-loading vk-like" title="Загрузка..." />');
  } else {
    $postloader.hide();
    var $loader = $postloader.next();

    if ($loader.hasClass('postloader-progress')) {
      $loader.css('visibility', 'visible').show();
    } else {
      $loader = $('<div class="ajax-loading vk-like" title="Загрузка..." />').insertAfter($postloader);
    }
  }

  var url = $postloader.data('remote');
  if (!url || url == '') {
    $postloader.trigger('postloader:trigger');
  } else {
    $postloader.data('locked', true);
    $.getJSON(url, function(data) {
      var $data = $(data.content);
      // передаём в колбек данные, а затем трём элемент
      $postloader.trigger('postloader:success', [$data]);
      // после колбеказабираем данные из filtered-data
      $data = $postloader.data('filtered-data');

      if (new_postloader) {
        $postloader.replaceWith($data);
      } else {
        $postloader.remove();
        $loader.replaceWith($data);
      }

      process_current_dom();
      $postloader.data('locked', false);

      $('.ajax').trigger('postloader:success');
    });
  }
});

// удаляем уже имеющиеся подгруженные элементы
$('.postloader').live('postloader:success', function(e, $data) {
  var filter = $(this).data('filter') || 'comment';
  var regex = new RegExp(filter + "-\\d+");

  var $present_entries = $('.' + filter + '-block');

  var exclude_selector = _.compact(_.map($present_entries, function(v,k) {
    var match = v.className.match(regex);
    if (match) {
      return "." + match[0];
    }
    return null;
  })).join(', ');

  $(this).data('filtered-data', $data.not(exclude_selector));
});
