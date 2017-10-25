/*
 * jQuery plugin for delayed hover mouse_out event.
 * It works similar to original jQuery hover but has additional parameter - mouse_out_timeout.
 * It executes mouse_out_callback with mouse_out_timeout delay, so mouse_out_callback wont be executed when mouse cursor quickly returned to hoverable area.
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
    hover_delayed: function(mouse_over_callback, mouse_out_callback, mouse_over_delay, mouse_out_delay) {
      return this.each(function() {
        var over_timer = null;
        var out_timer = null;

        $(this).hover(function(e) {
          if (out_timer) {
            clearInterval(out_timer);
            out_timer = null;
          }
          if (!over_timer) {
            var _this = this;
            over_timer = setInterval(function() {
              over.call(_this, e);
            }, mouse_over_delay);
          }
        }, function(e) {
          if (over_timer) {
            clearInterval(over_timer);
            over_timer = null;
          }
          if (!out_timer) {
            var _this = this;
            out_timer = setInterval(function() {
              out.call(_this, e);
            }, mouse_out_delay);
          }
        });

        function over(e) {
          mouse_over_callback.call(this, e);
          clearInterval(over_timer);
          over_timer = null;
        }
        function out(e) {
          mouse_out_callback.call(this, e);
          clearInterval(out_timer);
          out_timer = null;
        }
      });
    }
  });
})(jQuery);
