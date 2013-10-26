(function($){
  var urls_cache = {def: document.title}
  $.fn.extend({
    makeSliderable: function(opts) {
      var defaults = {
        $controls: $(),
        $next: $(),
        $prev: $(),
        direction: 'horizontal',
        remote_load: false,
        history: false,
        easing: 'swing',
        onslide: function() {}
      };
      var options = $.extend(defaults, opts);

      return this.each(function() {
        var $slider = $(this);
        var $view_content = $slider.find('.view-content');
        var $slides = $slider.find('.slide');
        if (options.direction == 'horizontal') {
          var slide_width = $slides.data('width') || (
              $slides.width() + parseInt($slides.css('margin-right').match(/\d+/)[0]) +parseInt($slides.css('margin-left').match(/\d+/)[0])
            );
        }
        if (options.direction == 'vertical') {
          var slide_height = $slides.data('height') || (
              $slides.height() + parseInt($slides.css('margin-top').match(/\d+/)[0]) + parseInt($slides.css('margin-bottom').match(/\d+/)[0])
            );
        }
        var current_position = 0;

        // next/prev buttons
        options.$next.add(options.$prev).bind(options.history ? 'slider:click' : 'click', function() {
          current_position = ($(this).hasClass('control-next')) ? current_position+1 : current_position-1;
          if (current_position < 0) {
            current_position = $slides.length-1;
          }
          if (current_position > $slides.length-1) {
            current_position = 0;
          }
          $('.main-slider1 .view-content').animate({'marginLeft' : slide_width*(-current_position)});
          $view_content.animate({'marginLeft' : slide_width*(-1*current_position)}, 500, options.easing, function() { });
        });

        // клик на контрол слайдера
        $(options.$controls.selector).live(options.history ? 'slider:click' : 'click', function(e, no_clear) {
          var $control = $(this);
          var $selected = $('.slide > .selected');

          var func = arguments.callee;
          if (options.remote_load && func.mutex) {
            return false;
          } else if (options.remote_load) {
            func.mutex = true;
          }
          //current_position = index;
          // адрес, с которого грузить страницу
          if (options.history) {
            var remote_url = ($control.children('a').attr('href') || $control.children('span.link').data('href')).replace(/http:\/\/.*?\//, '/').replace('#', '/');
          }
          // тип страницы
          var page = $control.attr('class').match(/slider-control-([\w-]+)/)[1]
          var $target = $('.slide > .'+page).first();
          // очистка всего предыдущего
          if (!no_clear) {
            $selected.trigger('ajax:clear', page);
          }
          $selected.removeClass('selected');

          $target.addClass('selected');
          if ($target[0] != $selected[0]) {
            if ($selected.hasClass('masonry')) {
              $selected.data('height', $selected.height());
            }
            $target.css('height', $target.data('height') || '100%');
          }

          current_position = $target.parent().index();
          // если анимация идёт, останавливаем её
          if ($view_content.is(':animated')) {
            $view_content.stop(true, false);
          }
          $view_content.animate(options.direction == 'horizontal' ? {'marginLeft': slide_width*(-1*current_position)} : {'marginTop': slide_height*(-1*current_position)},
                                //$selected.get(0) == $target.get(0) ? 0 : 500,
                                500,
                                options.easing, function() {
                                  $target.trigger('slide:success');

                                  var $slide = $('.slide > .selected', $view_content).parent();
                                  var slide_offset = $slide.offset().left;
                                  var page_offset = $slide.parents('.page').offset().left;

                                  if ((slide_offset < 0 || Math.abs(slide_offset - page_offset) > 15) && !$slide.children('.no-animation').length) { // на странице пользователя блок списка с no-animation сдвинут
                                    $view_content.hide();
                                    _.delay(function() { $view_content.show(); });
                                  }
                                });
          // загрузка страницы после конца анимации слайдера
          if (options.remote_load) {
            // загрузку делаем только если еще нет контента
            if ($target.children('div,section,form,h2').length == 0 || $target.children('div.clear-marker,.ajax-loading').length > 0) {
              //console.log('ajax')
              var width = $target.width() / 2 - 16;
              $target.addClass('ajax');
              if ($target.children('div').length == 0) {
                $target.html('<div class="ajax-loading" title="Загрузка..." style="height: 500px;" />');
              }

              $('.ajax').one('ajax:success', function() {
                if ($target[0] != $selected[0]) {
                  $('.slide > div:not(.'+ page +')').css('height', $target.height());
                }
                //$slider.syncHeight($target.parent());
                $(this).removeClass('ajax');
                func.mutex = false;
                urls_cache[page] = document.title;
              }).one('ajax:failure', function() {
                $(this).removeClass('ajax');
                func.mutex = false;
              });
              do_ajax(remote_url);
            } else {
              if ($target[0] != $selected[0]) {
                $('.slide > div:not(.'+ page +')').css('height', $target.height());
              }
              //$slider.syncHeight($target.parent());
              $target.trigger('cache:success');
              func.mutex = false;
              document.title = urls_cache[page] || urls_cache.def;
            }
          }
          options.onslide($control, $($view_content.children().get(current_position)));
          return false;
        });
      });
    }//,
    // выравнивание высоты элемента по высоте другого
    //syncHeight: function(target, force) {
      //return this.each(function() {
        //if (!force && target.find('.no-height-resize').length > 0) {
          //return;
        //}
        //$(this).animate({'height': $(target).height()});
      //});
    //}
  });
})(jQuery);
