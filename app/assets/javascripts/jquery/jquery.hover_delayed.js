/*
 * jQuery plugin for delayed hover mouse_out event.
 * It works similar to jQuert hover but has additional parameter - mouse_out_timeout.
 * It executes mouse_out callback with mouse_out_timeout delay, so mouse_out callback wont be executed when mouse cursor quickly returned to hoverable area.
 *
 * Usage:
 *  $('some selector').hover_delayed(function() {
 *    // This is mouse_over callback code
 *  }, function() {
 *    // This is mouse_out callback code
 *  }, mouse_out_timeout_in_milliseconds);
 *
 *
 * Copyright (c) 2012 Andrey Sidorov
 * licensed under MIT license.
 *
 * https://
 *
 * Version: 0.1
 */
(function($) {
  $.fn.extend({
    hover_delayed: function(mouse_over_callback, mouse_out_callback, mouse_out_delay) {
      return this.each(function() {
        var out_timer = null;
        $(this).hover(function() {
          mouse_over_callback();

          if (out_timer) {
            clearInterval(out_timer);
            out_timer = null;
          }
        }, function() {
          if (!out_timer) {
            out_timer = setInterval(out, mouse_out_delay);
          }
        });

        function out() {
          mouse_out_callback();
          clearInterval(out_timer);
          out_timer = null;
        }
      });
    }
  });
})(jQuery);
