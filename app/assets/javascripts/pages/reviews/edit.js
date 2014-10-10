var root = '.slide > .reviews-edit';
var loaded = false;

$(root).live('ajax:success cache:success', function(e) {
  loaded = true;
  var $root = $(this);
  // голосовалки
  $('.rate-block', $root).makeRateble({
    '$form': false,
    'callback': function(id, value) {
      $('#review_'+id, $root).val(value);
    }
  });
  // подсказка о спойлере
  $('.notice', $root).tipsy({gravity: 's'});

  // при редактируемом обзоре подтверждений никаких не запрашиваем
  if ($('.shiki-editor textarea', root).val().length) {
    $('.about .accept', $root).trigger('click');
    $('.about .final-accept', $root).trigger('click');
  }
}).live('ajax:clear', function(e, data) {
  // очистка контента, чтобы в следующий раз загрузился новый
  if ($.isReady && loaded) {
    $(this).append('<div class="clear-marker"></div>');
  }
});

if (!('I18N' in window)) {
  window.I18N = {};
}
I18N.text = "Текст обзора";
I18N.storyline = "Сюжет";
I18N.animation = "Рисовка";
I18N.characters = "Персонажи";
I18N.music = "Звуковой ряд";
I18N.overall = "Итоговая оценка";

// принятие условий написания обзора
//$('.about .accept', root).live('click', function() {
  //$(this).hide()
          //.parent()
          //.next()
            //.show();
//});
// принятие последенего условия написания обзора
//$('.about .final-accept', root).live('click', function() {
  //$(this).hide();
  //$('.forum-container', root).show()
  //$('.shiki-editor', root).focus();
//});
// создание обзора
$('.item-save, .item-apply', root).live('click', function(e, data) {
  $(this).parents('form').submit();
});
// обзор создан/отредактирован успешно
$('form', root).live('ajax:success', function(e, data) {
  var $reviews = $('.slide .reviews');
  if ($reviews.children().length > 1) {
    $reviews.append('<div class="clear-marker"></div>');
  }
  var $info = $('.slide .info');
  if ($info.children().length > 1) {
    $info.append('<div class="clear-marker"></div>');
  }

  $('.shiki-editor', root).hide();
  var $control = $('.slider-control-reviews').show()
                                             .children();

  // переход на обзоры с подсветкой только что созданного
  if ($control.attr('href')) {
    var url = $control.attr('href');
    $control.attr('href', data.url)
            .trigger('click')
            .attr('href', url);
  } else {
    var url = $control.data('href');
    $control.data('href', data.url)
            .trigger('click')
            .data('href', url);
  }
});
