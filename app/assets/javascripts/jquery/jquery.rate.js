(function($) {
  var RATINGS = [
    { from: 1, to: 1.99, text: 'Отвратительно', value: 1 },
    { from: 2, to: 2.99, text: 'Ужасно', value: 2 },
    { from: 3, to: 3.99, text: 'Очень плохо', value: 3 },
    { from: 4, to: 4.99, text: 'Плохо', value: 4 },
    { from: 5, to: 5.99, text: 'Более-менее', value: 5 },
    { from: 6, to: 6.99, text: 'Нормально', value: 6 },
    { from: 7, to: 7.99, text: 'Хорошо', value: 7 },
    { from: 8, to: 8.99, text: 'Отлично', value: 8 },
    { from: 9, to: 9.49, text: 'Великолепно', value: 9 },
    { from: 9.49, to: 10, text: 'Эпик вин!', value: 10 }
  ]

  var pending_requerst = false;
  $.fn.extend({
    makeRateble: function(opts) {
      return this.each(function() {
        var defaults = {
          round_values: true
        };
        var options = $.extend(defaults, opts);

        var o = options;
        o.$root = $(this);

        // иниализировать можнно лишь раз
        if (o.$root.data('rateable-initialized')) {
          return true;
        } else {
          o.$root.data('rateable-initialized', true);
        }

        o.$container = o.$root.children('.scores-outer');
        o.$label = $('#'+o.$container.attr('id')+'-label', o.$root);
        o.$description = $('#'+o.$container.attr('id')+'-label-description', o.$root);
        if (!('$form' in o)) {
          var $form = o.$container.parents('form');
          o.$form = $form.length ? $form : null;
        }

        o.user_score = parseFloat(o.$container.attr('scores-value'));
        if (isNaN(o.user_score)) {
          o.user_score = 0
        }

        //o.size = parseFloat(o.$container.width());
        o.size = 160.0;
        o.dot_one_offset = o.size/100;

        set_user_score(o.user_score, o);
        set_current_score(o.user_score, o);
        set_label(o.user_score, o);

        o.$container.mousemove(function(e) { // mouse move
          if (o.$container.hasClass('rated')) {
            return;
          }
          if (!$(this).hasClass('hovered')) {
            $(this).addClass('hovered');
          }
          var offset = (e.clientX - o.$container.offset().left);
          var score = Math.round(offset/o.size*10*100)/100;
          set_label(score, o);
          set_user_score(score, o);
        }).hover(function(e) { // mouse on
          if (o.$container.hasClass('rated') || pending_requerst) {
            return;
          }
          //$(this).addClass('hovered');
        }, function(e) { // mouse leave
          if (o.$container.hasClass('rated') || pending_requerst) {
            return;
          }
          set_label(o.user_score, o);
          set_user_score(o.user_score, o, true);
          $(this).removeClass('hovered');
        }).click(function(e) { // click
          if (o.$container.hasClass('rated')) {
            return;
          }
          var offset = (e.clientX - o.$container.offset().left);
          var score = Math.round(offset/o.size*10*100)/100;

          //o.user_score = get_normal_score(score, o);
          //$(this).trigger('mouseleave');

          o.current_score = score;

          if (o.$form) {
            o.$form.children('#rate_score').attr('value', get_normal_score(score, o));
            o.$form.submit();
          } else {
            o.user_score = get_normal_score(score, o);
            set_current_score(o.user_score, o, true);
            $(this).trigger('mouseleave');
          }
          if (o.callback) {
            o.callback(o.$container.attr('id').replace(/^scores-/, ''), o.user_score);
          }
        });

        if (!o.$form) {
          return;
        }
        o.$form.bind('ajax:before', function(e) {
          pending_requerst = true;
        }).bind('ajax:success', function(e, data, status, xhr) {

          o.user_score = data.score;
          set_current_score(o.user_score, o, true);

          var $this = $(this);
          pending_requerst = false;
          // курсор может быть уже на зоне с рейтингом, но точно не известно, поэтому будет проверено на первом mousemove
          $(document).one('mousemove', function(e) {
            var offset = o.$container.offset();
            if (!(e.pageX >= offset.left && e.pageX <= o.$container.width() && e.pageY >= offset.top && e.pageY <= o.$container.height())) {
              o.$container.trigger('mouseleave');
            }
          });
        }).bind('ajax:failure', function(e, xhr, status, error) {
          pending_requerst = false;
          // курсор может быть уже на зоне с рейтингом, но точно не известно, поэтому будет проверено на первом mousemove
          $(document).one('mousemove', function(e) {
            var offset = o.$container.offset();
            if (!(e.pageX >= offset.left && e.pageX <= o.$container.width() && e.pageY >= offset.top && e.pageY <= o.$container.height())) {
              o.$container.trigger('mouseleave');
            }
          });
        });
      });
    }
  });

  function set_user_score(score, options, animated) {
    var data = {left: (-1*options.dot_one_offset*10*(10-score))+'px'};
    if (animated) {
      options.$container.find('.user-score').stop(true, false).animate(data);
    } else {
      options.$container.find('.user-score').stop(true, false).css(data);
    }
  }

  function set_current_score(score, options, animated) {
    var data = {left: (-1*options.dot_one_offset*10*(10-score))+'px'};
    if (animated) {
      options.$container.find('.shade-score').stop(true, false).animate(data);
    } else {
      options.$container.find('.shade-score').stop(true, false).css(data);
    }
  }

  function set_label(score, options) {
    if (score >= 1) {
      if (!options.round_values) {
        var len = String(score).replace(/\d+\.?/, '').length;
        options.$label.html(len == 2 ? score : (len == 1 ? score+'0': score+'.00'));
      }

      for (var i = 0; i < RATINGS.length; i++) {
        if (score >= RATINGS[i].from && score <= RATINGS[i].to) {
          options.$description.html(RATINGS[i].text);
          if (options.round_values) {
            options.$label.html(RATINGS[i].value);
          }
          break;
        }
      }
    } else {
      options.$label.html('&nbsp;');
      options.$description.html('&nbsp;');
    }
  }

  function get_normal_score(score, options) {
    for (var i = 0; i < RATINGS.length; i++) {
      if (score >= RATINGS[i].from && score <= RATINGS[i].to) {
        if (options.round_values) {
          return RATINGS[i].value;
        }
        break;
      }
    }
    return 0;
  }

})(jQuery);
