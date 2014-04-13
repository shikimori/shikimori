// парсинг параметров из урла для анимелиста
function get_anime_params() {
  if ('params' in arguments.callee) {
    return arguments.callee.params;
  }
  var $link = $('.slider-control-animelist a');
  if (!$link.length) {
    return;
  }
  arguments.callee.params = new AniMangaParamsParser($link.attr('href').replace(/^http:\/\/.*?\//, '/'), location.href, function(data) {
    if (!data.match(/anime/)) {
      return;
    }
    $('.slide > .animelist').append('<div class="clear-marker"></div>');
    $('.slider-control-animelist a').attr('href', data)
                                    .trigger('click');
  }, $('.anime-filter'));
  return arguments.callee.params;
}

// парсинг параметров из урла для мангалиста
function get_manga_params() {
  if ('params' in arguments.callee) {
    return arguments.callee.params;
  }
  var $link = $('.slider-control-mangalist a');
  if (!$link.length) {
    return;
  }
  arguments.callee.params = new AniMangaParamsParser($link.attr('href').replace(/^http:\/\/.*?\//, '/'), location.href, function(data) {
    if (!data.match(/manga/)) {
      return;
    }
    $('.slide > .mangalist').append('<div class="clear-marker"></div>');
    $('.slider-control-mangalist a').attr('href', data)
                                    .trigger('click');
  }, $('.manga-filter'));
  return arguments.callee.params;
}

var list_cache = [];
$(function() {
  DEFAULT_LIST_SORT = $('.default-sort').data('value');
  $('.anime-filter .genres .collapse,.manga-filter .genres .collapse').trigger('click', true);
  get_anime_params();
  get_manga_params();
});

// активация списка
$('.animelist, .mangalist').live('ajax:success cache:success', function(e, data) {
  // тормозит на анимации
  $('.slide > .selected').addClass('no-animation');

  $('.animanga-filter').hide();
  if (this.className.match(/anime|manga/)) {
    var type = this.className.match(/anime/) ? 'anime' : 'manga';
    $('.'+type+'-filter').show();
    if (!this.className.match(/list/)) {
      (type == 'anime' ? get_anime_params : get_manga_params)().parse('/mylist/' + (
          $(this).parent().index() - (type == 'anime' ? 9 : 9+6)
        ) + '/order-by/my');
    } else if (this.className.match(/list/)/* && e.type == 'cache:success'*/) {
      (type == 'anime' ? get_anime_params : get_manga_params)().parse(location.href.replace(/http:\/\/.*?\//, '/'));
    }
  }

  apply_list_handlers();
  update_list_cache();
});

// при выборе сортировке будем ставить её в дефолтные
$('.anime-params-controls .orders li, .manga-params-controls .orders li').live('click', function() {
  if (IS_LOGGED_IN) {
    DEFAULT_LIST_SORT = $(this).attr('class').match(/order-by-([\w-]+)/)[1];
  }
});

// клики на фильтры по списку в начале страницы
$(document.body).on('click', '.ani-manga-list .link', function() {
  $(this).toggleClass('selected');
  var id = $(this).data('id');
  $('.animanga-filter:visible .mylist li.mylist-'+id).trigger('click');
});
// фокус по инпуту фильтра по тайтлу
$(document.body).on('focus', '.ani-manga-list .filter input', function() {
  if (!list_cache.length) {
    update_list_cache();
  }
});
// разворачивание свёрнутых блоков при фокусе на инпут
$(document.body).on('focus', '.ani-manga-list .filter input', function() {
  $('.collapsed', $(this).closest('.slide')).each(function() {
    if (this.style.display == 'block') {
      $(this).trigger('click');
    }
  });
});

var filter_timer = null;

// пишут в инпуте фильтра по тайтлу
$(document.body).on('keyup', '.ani-manga-list .filter input', function(e) {
  if (e.keyCode == 91 || e.keyCode == 18 || e.keyCode == 16 || e.keyCode == 17) {
    return;
  }

  if (filter_timer) {
    clearInterval(filter_timer);
    filter_timer = null;
  }
  filter_timer = setInterval(filter, 350);
});

// фильтрация списка пользователя
function filter() {
  clearInterval(filter_timer);
  filter_timer = null;

  var $slide = $('.slide > .selected');
  // разворачивание свёрнутых элементов
  var filter = $('.filter input', $slide).val().toLowerCase();
  var $entries = $('tr.selectable', $slide);

  _(list_cache).each(function(block) {
    var visible = false;

    for (var i = 0; i < block.rows.length; i++) {
      var entry = block.rows[i];
      if (entry.title.indexOf(filter) >= 0) {
        visible = true;

        if (entry.display != '') {
          entry.display = '';
          entry.node.style.display = '';
        }
      } else {
        if (entry.display != 'none') {
          entry.display = 'none';
          entry.node.style.display = 'none';
        }
      }
    }

    if (block.toggable) {
      block.$nodes.toggle(visible);
    }
    if (block.$only_show && visible) {
      block.$only_show.show();
    }
  });

  $.force_appear();
}

// кеширование всех строчек списка для производительности
function update_list_cache() {
  var $slide = $('.slide > .selected');
  list_cache = $('table', $slide).map(function() {
    var $table = $(this);
    var rows = $table
      .find('tr.selectable')
      .map(function() {
        return {
          node: this,
          title: String($(this).data('title')),
          display: this.style.display
        };
      }).toArray();

    var $nodes = $table.add($table.prev(':not(.collapse-merged)'));
    // если текущая таблица подгружена пагинацией, тоесть она без заголовка, то...
    if ($nodes.length == 1) {
      var klass = $table.prev().attr('class').match(/status-\d/)[0];
      var $only_show = $('.'+klass+':not(.collapse-merged)', $slide);
      $only_show = $only_show.add($only_show.next());
    }
    return {
      $nodes: $nodes,
      $only_show: $only_show,
      rows: rows,
      toggable: !$table.next('.postloader').length
    };
  });
}

// обработчики для списка
function apply_list_handlers() {
  // изменения статуса
  $('.selected .ani-manga-list tr.unprocessed').hover(function() {
    var $selector = $('.anime-status', this.parentNode);
    if (!$selector.length || $selector.is(':visible')) {
      return;
    }
    $('.anime-status', this).show();
    $('.anime-remove', this).show()
        .prev()
        .hide();
  }, function() {
    $('.anime-status', this).hide();
    $('.anime-remove', this).hide()
        .prev()
        .show();
  }).removeClass('unprocessed')
  .find('.tooltipped').tooltip($.extend($.extend({}, tooltip_options), {
    offset: [3, -300],
    position: 'bottom right',
    opacity: 1,
    onBeforeShow: null,
    onBeforeHide: null,
    moved: true,
    no_y_adjustment: true
  }));

  // изменения оценки/числа просмотренных эпизодов
  $('.selected .ani-manga-list .hoverable').unbind().hover(function() {
    var $current_value = $('.current-value', this);
    var $new_value = $('.new-value', this);
    // если нет элемента, то создаём его
    if ($new_value.length === 0) {
      var val = parseInt($current_value.children().html(), 10);
      if (!val && val !== 0) {
        val = 0;
      }
      var new_value_html = $current_value.data('field') != 'score' ?
          '<span class="new-value"><input type="text" class="input"/><span class="item-add"></span></span>' :
          '<span class="new-value"><input type="text" class="input"/></span>';
      $new_value = $(new_value_html)
        .children('input')
          .val(val)
          .data('counter', val)
          .data('max', 10)
          .data('min', 0)
          .data('field', $current_value.data('field'))
          .data('action', $current_value.parents('tr').data('action'))
          .parent()
        .insertAfter($current_value);
    }
    $new_value.show();
    $current_value.hide();
    $('.misc-value', this).hide();
  }, function() {
    if ($('.new-value input', this).is(':focus')) {
      return;
    }
    $('.new-value', this).hide();
    $('.current-value', this).show();
    $('.misc-value', this).show();
  }).click(function(e) {
    // клик на плюсик обрабатываем по дефолтному
    if (e.target && e.target.className == 'item-add') {
      return;
    }
    var $this = $(this);
    $this.trigger('mouseenter');
    $('input', $this).trigger('focus').select();
    e.stopPropagation();
    return false;
  });
}

// удаление из списка
$('.anime-remove').live('ajax:success', function() {
  $(this).closest('tr').remove();
  return false;
});

// обработчик для плюсика у числа эпизодов/глав
$('.selected .ani-manga-list .hoverable .item-add').live('click', function(e) {
  var $input = $(this).prev();
  $input.val(parseInt($input.val(), 10) + 1)
        .trigger('blur');
  e.stopPropagation();
  return false;
});
// обработчики для инпутов листа
$('.selected .ani-manga-list .hoverable input').live('blur', function() {
  var $this = $(this);
  $this.parent().parent().trigger('mouseleave');
  if (this.value < 0) {
    this.value = 0;
  }
  if ((parseInt(this.value, 10) || 0) == (parseInt($this.data('counter'), 10) || 0)) {
    return;
  }
  var $value = $this.parent().parent().find('.current-value');
  var prior_value = $value.html();
  $this.data('counter', this.value);
  $value.html($this.data('counter') == '0' ? '&ndash;' : $this.data('counter'));
  $.cursorMessage();
  $.post($this.data('action'), '_method=patch&rate['+$this.data('field')+']='+$this.attr('value'))
    .success(function() {
      $.hideCursorMessage();
    })
    .error(function() {
      $.hideCursorMessage();
      $value.html(prior_value);
      $.flash({alert: 'Произошла ошибка'});
    });
}).live('mousewheel', function(e) {
  var $this = $(this);
  if (!$this.is(':focus')) {
    return true;
  }
  if (e.originalEvent.wheelDelta && e.originalEvent.wheelDelta > 0) {
    this.value = Math.min((parseInt(this.value, 10) + 1 || 0), parseInt($this.data('max'), 10));
  } else if (e.originalEvent.wheelDelta) {
    this.value = Math.max((parseInt(this.value, 10) - 1 || 0), parseInt($this.data('min'), 10));
  }
  return false;
}).live('keydown', function(e) {
  var $this = $(this);
  if (e.keyCode == 38) {
    this.value = Math.min((parseInt(this.value, 10) + 1 || 0), parseInt($this.data('max'), 10));
  } else if (e.keyCode == 40) {
    this.value = Math.max((parseInt(this.value, 10) - 1 || 0), parseInt($this.data('min'), 10));
  } else if (e.keyCode == 27) {
    this.value = $this.data('counter');
    $this.trigger('blur');
  }
}).live('keypress', function(e) {
  if (e.keyCode == 13) {
    $(this).trigger('blur');
    e.stopPropagation();
    return false;
  }
});

// сортировка по клику на колонку
$('.order-control').live('click', function(e) {
  var type = $(this).data('order');
  $('.animanga-filter:visible .orders.anime-params li.order-by-'+type).trigger('click');
});

// скрытие слайдов с аниме
$('.slide > div').live('ajax:clear', function(e, page) {
  if (!page.match(/anime|manga/)) {
    $('.animanga-filter').hide();
  }
});
// активация изменения статуса
$('.selected .anime-status').live('click', function() {
  var $this = $(this);
  var $selector = $this.parents('td').children('.anime-status-selector');
  // если нет селектора - создаём
  if (!$selector.length) {
    $selector = $this
      .parents('.ani-manga-list')
      .children('.anime-status-selector')
      .clone()
        .data('field', $this.data('field'))
        .data('action', $this.parents('tr').data('action'));
    $this.parents('td').prepend($selector);
  }
  $selector.show();
  $this.hide();
  $(window).one('click', function(e) {
    if (e.target == $selector[0]) {
      return;
    }
    $selector.hide();
    e.stopPropagation();
    return false;
  });
  return false;
});
$('.selected .anime-status-selector').live('change', function(e) {
  var $this = $(this);

  $.cursorMessage();
  $.post($this.data('action'), '_method=patch&rate['+$this.data('field')+']='+$this.attr('value'))
    .success(function() {
      $.hideCursorMessage();
      $this.hide();
    })
    .error(function() {
      $.hideCursorMessage();
      $this.hide();
      $.flash({alert: 'Произошла ошибка'});
    });
  return false;
});
$('.selected .anime-status-selector').live('click', function(e) {
  e.stopPropagation();
  return false;
});

// подгрузка списка аниме
$('.selected .ani-manga-list .postloader').live('postloader:success', function(e, $data) {
  var $header = $data.filter('header:first');
  // при подгрузке могут быть 2 случая:
  // 1. подгружается совершенно новый блок, и тогда $header будет пустым
  // 2. погружается дальнейший контент уже существующего блока, и тогда...
  if ($('.ani-manga-list header.'+$header.attr('class')).length > 0) {
    // заголовок скрываем, ставим ему класс collapse-merged и collapse-ignored(чтобы раскрытие collapsed работало корректно), 
    // а так же таблице ставим класс merged и скрываем её заголовок
    $header
      .addClass('collapse-merged')
      .addClass('collapse-ignored')
      .hide()
      .next()
        .addClass('collapse-merged')
        .find('tr:first,tr.border')
          .hide();
  }
  _.delay(function() {
    apply_list_handlers();
    update_list_cache();
    var $input = $('.selected .ani-manga-list .filter input')
    if (!_.isEmpty($input.val())) {
      $input.trigger('keyup');
    }
  }, 250);
});
