// ajax
var pending_request = null;
// подгрузка части контента аяксом
function do_ajax(url, $postloader, break_pending) {
  return $.ajax({
    url: location.protocol+"//"+location.host+url,
    data: null,
    dataType: 'json',
    beforeSend: function (xhr) {
      if (pending_request && break_pending) {
        if ('abort' in pending_request) {
          pending_request.abort();
        } else {
          pending_request.aborted = true;
        }
        pending_request = null;
      }
      if ($(this).hasClass('disabled') || pending_request) {
        xhr.abort();
        return;
      }
      var cached_data = AjaxCacher.get(url);
      if (cached_data) {
        xhr.abort();
        // в кеше может быть ajaxRequest
        if ('abort' in cached_data && 'setRequestHeader' in cached_data) {
          var self = this;
          cached_data.success(function(data, status, xhr) {
            process_ajax(data, url, $postloader);
          }).complete(this.complete).error(this.error);
        } else {
          process_ajax(cached_data, url, $postloader);
          return;
        }
      }
      pending_request = this;
      // если подгрузка следующей страницы при прокруте, то никаких индикаций загрузки не надо
      if ($postloader) {
        return;
      }

      if ($('.ajax').children().length != 1 || $('.ajax').children('.ajax-loading').length != 1) {
        $('.ajax:not(.no-animation), .ajax-opacity').animate({opacity: 0.3});
        $('.ajax.no-animation').css({opacity: 0.3});
      }
      $.cursorMessage();
    },
    success: function (data, status, xhr) {
      AjaxCacher.push(url, data);
      if ('aborted' in this && this.aborted) {
        return;
      }
      process_ajax(data, url, $postloader);
    },
    complete: function (xhr) {
      pending_request = null;
    },
    error: function (xhr, status, error) {
      pending_request = null;

      try {
        var errors = JSON.parse(xhr.responseText);
      } catch(e) {
        var errors = {};
      }
      if (xhr.responseText.match(/invalid/)) {// || xhr.responseText.match(/unauthenticated/)) {
        $.flash({alert: 'Неверный логин или пароль'});
      } else if (xhr.status == 401) {
        $.flash({alert: 'Вы не авторизованы'});
        $('#sign_in').trigger('click');
      } else if (xhr.status == 403) {
        $.flash({alert: 'У вас нет прав для данного действия'});
      } else if (_.size(errors)) {
        $.flash({alert: _.map(errors, function(v, k) { return "<strong>"+(k in I18N ? I18N[k] : k)+"</strong> "+v; }).join('<br />')});
      } else {
        $.flash({alert: 'Пожалуста, повторите попытку позже'});
      }

      $.hideCursorMessage();
      $('.ajax').trigger('ajax:failure')
                .unbind('ajax:success');
      history.back();
    }
  });
}
function process_ajax(data, url, $postloader) {
  return $postloader ? process_ajax_postload(data, url, $postloader) : process_ajax_response(data, url);
}
// обработка контента, полученного при прокрутке вниз
function process_ajax_postload(data, url, $postloader) {
  $postloader.replaceWith(data.content);
  paginate(data, true);
}
// обработка контента, полученного при подгрузке произвольной страницы
function process_ajax_response(data, url) {
  var $content = $('.ajax');
  $content.html(data.content);

  if (data.title_page) {
    document.title = (('current_page' in data) && data.current_page > 1 ? 'Страница ' + data.current_page + ' / ' : '')
                      + ('head_title' in data ? data.head_title : '')
                      + (data.title_page.constructor == Array ? data.title_page.reverse().join(' / ') : data.title_page)
                      + ' / Шикимори';

    var title = data.h1 || data.title_page;
    $('.new-header h1, .forum-nav .title, .head.ajaxable h1').html(title);
    $('.new-header .description, .forum-nav .notice, .head.ajaxable .notice').html(data.title_notice);
  }

  // отслеживание страниц в гугл аналитике и яндекс метрике
  if (url) {
    if ('_gaq' in window) {
      _gaq.push(['_trackPageview', url.replace(/\.json$/, '')]);
    }
    if ('yaCounter7915231' in window) {
      yaCounter7915231.hit(url.replace(/\.json$/, ''))
    }
  }

  paginate(data);
  $content.add('.ajax-opacity')
          .stop(true, false)
          .css('opacity', 1);

  $.hideCursorMessage();
  $('.ajax').trigger('ajax:success', data)
            .unbind('ajax:failure');
}
// pagination
function paginate(data, postlaoded) {
  if (!('Controls' in window)) {
    return;
  }
  if (postlaoded) {
    var $current = Controls.$link_current;
    $current.html($current.html().replace(/-\d+|$/, '-'+data.current_page));
    Controls.$link_title.html('Страницы');
  } else {
    Controls.$link_title.html('Страница');
    Controls.$link_current.html(data.current_page);
    Controls.$link_total.html(data.total_pages);

    Controls.$link_first.attr('href', data.first_page || "")
                        .attr('action', data.first_page);
    if (data.first_page) {
      Controls.$link_first.removeClass('disabled');
    } else {
      Controls.$link_first.addClass('disabled');
    }

    Controls.$link_prev.attr('href', data.prev_page || "")
                       .attr('action', data.prev_page);
    if (data.prev_page) {
      Controls.$link_prev.removeClass('disabled');
    } else {
      Controls.$link_prev.addClass('disabled');
    }

    Controls.$link_last.attr('href', data.last_page || "")
                       .attr('action', data.last_page);
    if (data.last_page) {
      Controls.$link_last.removeClass('disabled');
    } else {
      Controls.$link_last.addClass('disabled');
    }
  }

  Controls.$link_next.attr('href', data.next_page || "")
                     .attr('action', data.next_page);
  if (data.next_page) {
    Controls.$link_next.removeClass('disabled');
  } else {
    Controls.$link_next.addClass('disabled');
  }

  //if (!postlaoded) {
    Controls.$ajax.trigger('pagination:success');
  //}
}
