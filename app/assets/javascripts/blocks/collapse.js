// сворачивание/разворачивание спойлеров по клику
$(document).on('click', '.collapse', function(e, custom) {
  var $this = $(this);
  var is_hide = $this.children('.action').html().match(/свернуть/);
  var in_comment = $this.parents('.topic-block,.comment-block').length > 0;

  // блок-заглушка, в которую сворачивается контент
  var $placeholder = $this.next();
  if (!$placeholder.hasClass('collapsed')) {
    $placeholder = $placeholder.next();
  }

  // еонтент, убираемый под спойлер
  var $hideable = $placeholder.next();
  // если в $hideable ничего, значит надо идти на уровень выше и брать next оттуда
  if ($hideable.length == 0) {
    $hideable = $this.parent().next();
  }

  // если внутри спойлера картинки, то отображение дефолтное
  if ($hideable.find('img').not('.smiley').length) {
    in_comment = false;
  }
  // если спойлер внутри комментария, то у него особое отображение
  if (in_comment) {
    $hideable.addClass('dashed').attr('title', 'свернуть спойлер');
  }
  // скрываем не только следующий элемент, но и все последующие с классом collapse-merged
  while ($hideable.last().next().hasClass('collapse-merged')) {
    $hideable = $hideable.add($hideable.last().next());
  }
  // при этом игнорируем то, что имеет класс collapse-ignored
  if ($hideable.length > 1) {
    $hideable = $hideable.filter(':not(.collapse-ignored)');
  }
  if (is_hide) {
    $placeholder.show();
    $hideable.hide();
  } else {
    // при показе спойлера можем просто показать его содержимое, открыв элемент
    //if (!$hideable.data('href')) {
      $hideable.show();
      $placeholder.hide();
    //} else {
      //// а можем подгрузить контент с сервера
      //$placeholder.html('<img src="/images/loading.gif" alt="загрузка..." title="загрузка..." />');
      //$hideable.load($hideable.data('href'), function() {
        //$placeholder.hide();
      //});
      //$hideable.data('href', null);
    //}
  }

  // корректный текст для кнопки действия
  $this.children('.action').html(function() {
    var $this = $(this);
    if ($this.hasClass('half-hidden')) {
      if (is_hide) {
        $this.hide();
      } else {
        $this.show();
      }
    }
    if (in_comment) {
      return '';
    } else {
      return is_hide ? $this.html().replace('свернуть', 'развернуть') : $this.html().replace('развернуть', 'свернуть');
    }
  });

  if (!custom) {
    var id = $this.attr('id');
    if (id && id != '' && id.indexOf('-') != -1) {
      var name = id.split('-').slice(1).join('-')+';';
      var collapses = $.cookie("collapses") || "";
      if (is_hide && collapses.indexOf(name) == -1) {
        $.cookie("collapses", collapses+name, {expires: 730, path: '/'});
      } else if (!is_hide && collapses.indexOf(name) != -1) {
        $.cookie("collapses", collapses.replace(name, ''), {expires: 730, path: '/'});
      }
    }
  }
  $placeholder.next().trigger('show');

  // всем картинкам внутри спойлера надо заново проверить высоту
  $hideable.find('img').addClass('check-width');
  process_current_dom();
});
// клик на "свернуть"
$(document).on('click', '.collapsed', function() {
  var $this = $(this);
  var $trigger = $this.prev();
  if (!$trigger.hasClass('collapse')) {
    $trigger = $trigger.prev();
  }
  $trigger.trigger('click');
});
// клик на содержимое спойлера
$(document).on('click', '.spoiler.target', function() {
  var $this = $(this);

  if (!$this.hasClass('dashed')) {
    return;
  }
  $this.hide()
         .prev()
         .show()
           .prev()
           .show();
});
