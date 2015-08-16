/**
 * @license
 * jQuery Tools 1.2.5 Tooltip - UI essentials
 *
 * NO COPYRIGHTS OR LICENSES. DO WHAT YOU LIKE.
 *
 * http://flowplayer.org/tools/tooltip/
 *
 * Since: November 2008
 * Date:    Wed Sep 22 06:02:10 2010 +0000
 */
(function($) {
  // static constructs
  $.tools = $.tools || {version: '1.2.5'};

  $.tools.tooltip = {
    conf: {
      // default effect variables
      effect: 'toggle',
      fadeOutSpeed: "fast",
      predelay: 0,
      delay: 30,
      opacity: 1,
      tip: 0,

      // 'top', 'bottom', 'right', 'left', 'center'
      position: ['top', 'center'],
      offset: [0, 0, 0],
      relative: false,
      cancelDefault: true,

      // type to event mapping
      events: {
        def:       "mouseenter,mouseleave",
        input:     "focus,blur",
        widget:    "focus mouseenter,blur mouseleave",
        tooltip:    "mouseenter,mouseleave"
      },

      // 1.2
      layout: '<div/>',
      tipClass: 'tooltip'
    },

    addEffect: function(name, loadFn, hideFn) {
      effects[name] = [loadFn, hideFn];
    }
  };


  var effects = {
    toggle: [
      function(done) {
        var conf = this.getConf(), tip = this.getTip(), o = conf.opacity;
        if (o < 1) { tip.css({opacity: o}); }
        tip.show();
        done.call();
      },

      function(done) {
        this.getTip().hide();
        done.call();
      }
    ],

    fade: [
      function(done) {
        var conf = this.getConf();
        this.getTip().fadeTo(conf.fadeInSpeed, conf.opacity, done);
      },
      function(done) {
        this.getTip().fadeOut(this.getConf().fadeOutSpeed, done);
      }
    ]
  };


  /* calculate tip position relative to the trigger */
  function getPosition($trigger, $tip, conf, no_show_or_hide) {
    var is_relative = $trigger.data('relative') == undefined ? conf.relative : $trigger.data('relative');
    // get origin top/left position
    var top = is_relative ? $trigger.position().top : $trigger.offset().top,
       left = is_relative ? $trigger.position().left : $trigger.offset().left,
       abs_left = $trigger.offset().left,
       abs_top = $trigger.offset().top,
       pos = conf.position[0];

    if (!no_show_or_hide) {
      $tip.show()
    }
    $tip.removeClass('tooltip-bottom')
        .removeClass('tooltip-center');

    top  -= $tip.outerHeight() - conf.offset[0] - ($trigger.data('offset-top') || 0);
    left += $trigger.outerWidth() + conf.offset[1] - ($trigger.data('offset-left') || 0);
    abs_left += $trigger.outerWidth() + conf.offset[1];

    // iPad position fix
    if (/iPad/i.test(navigator.userAgent)) {
      top -= $(window).scrollTop();
    }

    // adjust Y
    var height = $tip.outerHeight() + $trigger.outerHeight();
    if (pos == 'center')   { top += height / 2; }
    if (pos == 'bottom')   { top += height; }

    // adjust X
    pos = conf.position[1];
    var width = $tip.outerWidth() + $trigger.outerWidth();
    if (pos == 'center') {
      left -= width / 2;
      abs_left -= width / 2;
    }
    if (pos == 'left') {
      left -= width;
      abs_left -= width;
    }

    var tip_width = $tip.find('.tooltip-inner').outerWidth() + $tip.find('.tooltip-arrow').outerWidth();
    var tip_height = $tip.find('.tooltip-inner').outerHeight();

    // вписывание тултипа в экран по горизонтали
    var offscreen_right_offset = (abs_left + tip_width) - $(window).width();
    if (!$trigger.data('no-align') && (offscreen_right_offset > 0 || conf.place_to_left || $trigger.data('place-to-left'))) {
      var tip_full_offset = (tip_width + $trigger.outerWidth() + $tip.find('.tooltip-arrow').outerWidth()) + ($trigger.data('offset-left') || 0)*2 + ($trigger.data('offset-left-right') || 0);
      var new_left = left - tip_full_offset;

      var left_border = is_relative ? $trigger.offset().left - $trigger.position().left : 0;

      if (new_left > -left_border || conf.place_to_left || $trigger.data('place-to-left')) {
        left = new_left + (conf.offset[2] || 0);
        $tip.addClass('tooltip-left');
      } else if (-new_left < offscreen_right_offset) {
        left = 0;
        $tip.addClass('tooltip-moved');
      } else {
        left -= offscreen_right_offset + 10;
        $tip.addClass('tooltip-moved');
      }
    } else {
      $tip.removeClass('tooltip-left');
    }

    var $arrow = $tip.find('.tooltip-arrow');
    // запоминаем изначальную высоту стрелки
    if (!$arrow.data('top')) {
      $arrow.data('top', parseInt($arrow.css('top')));
    }
    $arrow.css('top', $arrow.data('top'));

    // вписывание тултипа в экран по вертикали
    var offscreen_bottom_offset = (abs_top + tip_height) - $(window).scrollTop() - $(window).height();
    if (!$trigger.data('no-align')) {
      if (offscreen_bottom_offset > 0 && !conf.no_y_adjustment) {
        top -= offscreen_bottom_offset + 10;
      }

      if (offscreen_bottom_offset > 0) {
        $arrow.css('top', [$arrow.data('top') + offscreen_bottom_offset, tip_height - $arrow.data('top')].min());
      }
      var offscreen_top_offset = abs_top - $(window).scrollTop();
      if (offscreen_top_offset < 0) {
        top -= offscreen_top_offset - 10;
      }
    }

    if (conf.moved) {
      $tip.addClass('tooltip-moved');
    }

    if (!no_show_or_hide) {
      $tip.hide();
    }
    return { top: top, left: left };
  }



  function Tooltip(trigger, conf) {
    var self = this,
       fire = trigger.add(self),
       tip,
       timer = 0,
       pretimer = 0,
       title = trigger.data("do-not-use-title") ? null : trigger.attr("title"),
       tipAttr = trigger.attr("data-tooltip"),
       effect = effects[conf.effect],
       shown,

       // get show/hide configuration
       isInput = trigger.is(":input"),
       isWidget = isInput && trigger.is(":checkbox, :radio, select, :button, :submit"),
       type = trigger.attr("type"),
       evt = conf.events[type] || conf.events[isInput ? (isWidget ? 'widget' : 'input') : 'def'];


    // check that configuration is sane
    if (!effect) { throw "Nonexistent effect \"" + conf.effect + "\""; }

    evt = evt.split(/,\s*/);
    if (evt.length != 2) { throw "Tooltip: bad events configuration for " + type; }


    // trigger --> show
    trigger.bind(evt[0], function(e) {
      clearTimeout(pretimer);
      var predelay = trigger.data('predelay') || conf.predelay;
      if (predelay) {
        pretimer = setTimeout(function() { self.show(e); }, predelay);

      } else {
        self.show(e);
      }

    // trigger --> hide
    }).bind(evt[1], function(e)  {
      clearTimeout(pretimer);

      var delay = trigger.data('delay') || conf.delay;
      if (delay)  {
        timer = setTimeout(function() { self.hide(e); }, delay);

      } else {
        self.hide(e);
      }

    });


    // remove default title
    if (title && conf.cancelDefault) {
      trigger.removeAttr("title");
      trigger.data("title", title);
    }

    $.extend(self, {
      show: function(e) {
        // для устройств с тачскрином и узких экранов тултипы отключаем
        if (('ontouchstart' in window) || (navigator.MaxTouchPoints > 0) || (navigator.msMaxTouchPoints > 0) || is_mobile()) {
          return;
        }
        // tip not initialized yet
        if (!tip) {
          // data-tooltip
          if (tipAttr) {
            tip = $(tipAttr);

          // single tip element for all
          } else if (conf.tip) {
            tip = $(conf.tip).eq(0);

          // remote tooltip
          } else if (!trigger.data('local-tooltip') && (trigger.data('tooltip_url') || trigger.data('href') || trigger.attr('href'))) {
            tip = $(conf.defaultTemplate)
              .addClass(conf.tipClass)
              .css('z-index', parseInt(trigger.parents('.tooltip').css('z-index')) || 1)
              .hide()
              .appendTo(document.body);

            _.delay(function() {
              tooltip_url = trigger.data('tooltip_url') || trigger.data('href') || trigger.attr('href').replace(/(\?|$)/, '/tooltip$1')
              tip.find('.tooltip-details').load(tooltip_url, function() {
                // если есть только картинка, то ставим класс tooltip-image
                var $this = $(this);
                var $desc = $this.find('.tooltip-desc');
                if ($desc.length && $desc.html() == '' && $this.find('img').length) {
                  $this.parents('.tooltip').addClass('tooltip-image');
                }
                $this.process();
                // после подгрузки надо тултип перересовать, если он видимый
                _.delay(function() {
                  if (tip.css('display') == 'none') {
                    return;
                  }

                  var top = parseInt(tip.css('top'));
                  var left = parseInt(tip.css('left'));

                  var pos = getPosition(trigger, tip, conf, true);
                  if (Math.abs(top - pos.top) > 20 || Math.abs(left - pos.left) > 20) {
                    tip.stop(true, true).css({top: pos.top, left: pos.left});
                  }
                }, 50);
              });
            }, 100);
            trigger.attr('data-remote', null);
            trigger.attr('tooltip', null);
          // autogenerated tooltip
          //} else if (title) {
            //tip = $(conf.layout).addClass(conf.tipClass).appendTo(document.body)
              //.hide().append(title);

          // manual tooltip
          } else {
            tip = trigger.next();
            if (!tip.length) { tip = trigger.parent().next(); }
          }

          if (!tip.length) { throw "Cannot find tooltip for " + trigger;  }
        }

        if (self.isShown()) { return self; }

         // stop previous animation
        tip.stop(true, true);

        // get position
        var pos = getPosition(trigger, tip, conf);

        // restore title for single tooltip element
        if (conf.tip) {
          tip.html(trigger.data("title"));
        }

        // onBeforeShow
        e = e || $.Event();
        e.type = "onBeforeShow";
        fire.trigger(e, [pos]);
        //if (e.isDefaultPrevented()) { return self; }

        // onBeforeShow may have altered the configuration
        pos = getPosition(trigger, tip, conf);

        // set position
        tip.css({position:'absolute', top: pos.top, left: pos.left});

        shown = true;

        // invoke effect
        effect[0].call(self, function() {
          e.type = "onShow";
          shown = 'full';
          fire.trigger(e);
        });


        // tooltip events
        var event = conf.events.tooltip.split(/,\s*/);

        if (!tip.data("__set")) {

          tip.bind(event[0], function() {
            clearTimeout(timer);
            clearTimeout(pretimer);
          });

          if (event[1] && !trigger.is("input:not(:checkbox, :radio), textarea")) {
            tip.bind(event[1], function(e) {

              // being moved to the trigger element
              if (e.relatedTarget != trigger[0]) {
                trigger.trigger(evt[1].split(" ")[0]);
              }
            });
          }

          tip.data("__set", true);
        }

        return self;
      },
      hide: function(e) {
        if (!tip || !self.isShown()) { return self; }

        // onBeforeHide
        e = e || $.Event();
        e.type = "onBeforeHide";
        fire.trigger(e);
        //if (e.isDefaultPrevented()) { return; }

        shown = false;

        effects[conf.effect][1].call(self, function() {
          e.type = "onHide";
          fire.trigger(e);
        });

        return self;
      },

      isShown: function(fully) {
        return fully ? shown == 'full' : shown;
      },

      getConf: function() {
        return conf;
      },

      getTip: function() {
        return tip;
      },

      getTrigger: function() {
        return trigger;
      }

    });

    // callbacks
    $.each("onHide,onBeforeShow,onShow,onBeforeHide".split(","), function(i, name) {

      // configuration
      if ($.isFunction(conf[name])) {
        $(self).bind(name, conf[name]);
      }

      // API
      self[name] = function(fn) {
        if (fn) { $(self).bind(name, fn); }
        return self;
      };
    });

  }

  // jQuery plugin implementation
  $.fn.tooltip = function(conf) {
    // return existing instance
    var api = this.data("tooltip");
    if (api) { return api; }

    conf = $.extend(true, {}, $.tools.tooltip.conf, conf);

    // position can also be given as string
    if (typeof conf.position == 'string') {
      conf.position = conf.position.split(/,?\s/);
    }

    // install tooltip for each entry in jQuery object
    this.each(function() {
      api = new Tooltip($(this), conf);
      $(this).data("tooltip", api);
    });

    return conf.api ? api: this;
  };

}) (jQuery);
