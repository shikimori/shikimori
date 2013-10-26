// генерация истории аниме/манги
function build_history() {
  var $history_block = $('.menu-right .history');
  // тултипы истории
  $('.person-tooltip', $history_block).tooltip({ position: 'top right', offset: [-28, -28], relative: true, place_to_left: true });
  // подгрузка тултипов истории
  var history_load_triggered = false;
  //$node.hover(function() {
  $history_block.hover(function() {
    if (history_load_triggered) {
      return;
    }
    history_load_triggered = true;
    $.getJSON($(this).attr('data-remote'), function(data) {
      for (var id in data) {
        var $tooltip = $('.tooltip-details', '#history-entry-'+id+'-tooltip');
        if (!$tooltip.length) {
          continue;
        }
        if (!data[id].length) {
          $('#history-entry-'+id+'-tooltip').children().remove();
        } else {
          $tooltip.html(_.map(data[id], function(v,k) { return '<a href="' + v.link + '" rel="nofollow">' + v.title + '</a>' }).join('<br />'));
        }
      }
    });
  });
}

$(function() {
  // anime history block
  build_history();
  // anime history tooltips
  $('.person-tooltip').tooltip({ position: 'top right', offset: [-28, -22], relative: true, place_to_left: true });

  // slides
  $('.slider-control').click(function(e) {
    // we should ignore middle button click
    if (in_new_tab(e)) {
      return;
    }
    $.history.load(($(this).children('a').attr('href') || $(this).children('span.link').data('href')).replace(/http:\/\/.*?\//, '/'));
    return false;
  });
  var $controls = $('.slider-control', $('.animanga-right-menu'));
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

  // history
  $.history.init(function(url) {
    var no_clear = false;
    if (url === "") {
      url = location.href.replace(/http:\/\/.*?\//, '/');
      no_clear = true;
    }

    if ('first_run' in arguments.callee) {
      var map_url = location.href.replace(/(http:\/\/.*?)\/.*/, '$1') + url;
      if ('MAP' in window && map_url in MAP) {
        // т.к. мы можем ходить по истории назад, то надо сделать активной нужную галерею
        //$(_.select($('.ad-nav [data-remote]'), function(v, k) { return $(v).attr('data-remote') == map_url })[0])
        $('.ad-nav').find("[data-remote='" + map_url + "']").parent().addClass('ad-active')
                                                            .parent().siblings().find('a').removeClass('ad-active');

        var $container = $('.gallery-container');
        $container.find('*').unbind();
        $container.find('.images-list').html(MAP[map_url].html);
        $container.find('.gallery-title').html(MAP[map_url].title);
        $container.find('.gallery-edit').attr('href', MAP[map_url].edit);
        $container.find('.ad-info').html('');
        $container.find('.ad-gallery').data('initialized', false);
        $($container).gallery({no_hide: true});
        return;
      } else {
        MAP = {};
      }
    } else {
      arguments.callee.first_run = true;
    }

    //$('.slider-control a[href$='+url+']').parent().trigger('slider:click', no_clear);
    var $target;
    $('.slider-control a,.slider-control span.link').each(function(k, v) {
      if (url.indexOf((this.className.indexOf('link') == -1 ? this.href : $(this).data('href')).replace(/http:\/\/.*?(?=\/)/, '')) != -1) {
        $target = $(this).parent();
      }
    });
    // отдельное правило для редактирования описаний
    if (url.match(/\/reviews\/\d+\/edit/)) {
      $target = $('.slider-control-reviews-edit');
    }
    var menu_url = ($target.children('a').attr('href') || $target.children('span.link').data('href')).replace(/http:\/\/.*?(?=\/)/, '');
    if (menu_url != url) {
      // в нужном li делается подмена урла, т.к. урл для загрузки страницы будет взят оттуда, а затем после загрузки страницы урл меняется назад
      $target.children().attr('href', url);
      $target.trigger('slider:click', no_clear);
      $target.children().attr('href', menu_url);
    } else {
      $target.trigger('slider:click', no_clear);
    }
  });

  // height fix for related anime
  var names = $('.entry-block .name');
  var max_height = _.max(names.map(function() { return $(this).height(); }));
  $('.entry-block .name p').each(function() {
    $this = $(this);
    var height = $this.height();
    $this.css('height', height);
    if ($this.parent().height() < max_height) {
      $this.addClass('f17');
    }
  });
  names.height(max_height);

  // rate
  $('.rate-statuses li').click(function() {
    var $this = $(this);
    if ($this.attr('id').match(/rate-status/)) {
      $('#rate_status').attr('value', $this.attr('id').match(/\d+/)[0]);
    }
    $this.parents('form').submit();
  });
  $('#rate-episodes,#rate-volumes,#rate-chapters').bind('change blur', function(e) {
    var $this = $(this);
    if (parseInt(this.value, 10) == parseInt($this.data('counter'), 10)) {
      return;
    }
    $this.data('counter', parseInt(this.value, 10));
    $this.parents('form').submit();
  })
  .bind('mousewheel', function(e) {
    if (!$(this).is(':focus')) {
      return true;
    }
    if (e.originalEvent.wheelDelta && e.originalEvent.wheelDelta > 0) {
      this.value = parseInt(this.value, 10) + 1;
    } else if (e.originalEvent.wheelDelta && parseInt(this.value, 10) > 1) {
      this.value = parseInt(this.value, 10) - 1;
    }
    return false;
  })
  .bind('keydown', function(e, inc) {
    if (e.keyCode == 38 || inc) {
      this.value = parseInt(this.value, 10) + 1;
    } else if (e.keyCode == 40 && parseInt(this.value, 10) > 1) {
      this.value = parseInt(this.value, 10) - 1;
    } else if (e.keyCode == 27) {
      this.value = $(this).data('counter');
      $(this).trigger('blur');
    }
  })
  .bind('keypress', function(e) {
    if (e.keyCode == 13) {
      $(this).trigger('blur');
      return false;
    }
  });
  $('#rate-block .item-add').bind('click', function() {
    $(this).parent().find('input').trigger('keydown', true).trigger('blur');
  });

  $('#rate-status-form, #rate-episodes-form, #rate-volumes-form, #rate-chapters-form').bind('ajax:success', function(e, data, status, xhr) {
    var $this = $(this);
    if ($this.attr('id') == 'rate-episodes-form' || $this.attr('id') == 'rate-volumes-form' || $this.attr('id') == 'rate-chapters-form') {
      $('#rate-episodes').attr('value', data.episodes).data('counter', parseInt(data.episodes, 10));
      $('#rate-volumes').attr('value', data.volumes).data('counter', parseInt(data.volumes, 10));
      $('#rate-chapters').attr('value', data.chapters).data('counter', parseInt(data.chapters, 10));
      $('#rate-status-'+data.status).trigger('status:select');
    } else {
      $('#rate-status-'+data.status).trigger('status:select');
      $('#rate-episodes').attr('value', data.episodes).data('counter', parseInt(data.episodes, 10));
      $('#rate-volumes').attr('value', data.volumes).data('counter', parseInt(data.volumes, 10));
      $('#rate-chapters').attr('value', data.chapters).data('counter', parseInt(data.chapters, 10));
    }
  }).bind('ajax:failure', function() {
    $('.add-to-list', this).removeClass('active');
  });
  // добавление в список
  $('#rate-add').bind('ajax:success', function(e, data, status, xhr) {
    var $this = $(this);
    // дефолтные значения
    $('#rate-status-'+data.status).trigger('status:select');
    $('#rate-episodes').attr('value', data.episodes).data('counter', parseInt(data.episodes, 10));
    $('#rate-volumes').attr('value', data.volumes).data('counter', parseInt(data.volumes, 10));
    $('#rate-chapters').attr('value', data.chapters).data('counter', parseInt(data.chapters, 10));
    $('#rate-rate').html(data.rate_content);
    $('.animanga-right-menu .scores-user').data('rateable-initialized', false).makeRateble();
    // скрыть себя, показать другую кнопку и показать блок статуса
    $this.parents('li').hide();
    $('#rate-del').parents('li').show();
    $('#rate-block').show().yellowFade(true);
  });
  // удаление из списка
  $('#rate-del').bind('ajax:success', function(e, data, status, xhr) {
    var $this = $(this);
    // скрыть себя, показать другую кнопку и скрыть блок статуса
    $this.parents('li').hide();
    $('#rate-add').parents('li').show();
    $('#rate-block').hide();
  });


  $('.rate-statuses li').bind('status:select', function() {
    $(this).addClass('selected')
        .siblings().removeClass('selected');
  });

  // user ratings
  var $scores_user = $('.animanga-right-menu .scores-user');
  if ($scores_user.is(':visible')) {
    $('.animanga-right-menu .scores-user').makeRateble();
  }

  // высота правого меню
  //$('.menu-right').height($('.menu-right-inner').height());
});

// клик по заголовку аниме
$('.anime-title a').live('click', function() {
  $('.slider-control-info a').trigger('click');
  return false;
});

// клик по кнопке комментировать
$('.actions .comment').live('click', function() {
  var editor_selector = '.slide > .info .comments .comments-container > .shiki-editor:first-child';
  if ($('.slide > .info').hasClass('selected')) {
    $(editor_selector).focus();
  } else {
    $('.slide > .info').one('slide:success', function() {
      // дождали завершения работы слайдера, и теперь либо переносим фокус, либо дожидаемся загрузки аякса
      var $editor = $(editor_selector);
      if ($editor.length) {
        $editor.focus();
      } else {
        $('.slide > .info').one('ajax:success', function() {
          _.delay(function() {
            $(editor_selector).focus();
          });
        });
      }
    });
    $('.slider-control-info').trigger('click');
  }
});
