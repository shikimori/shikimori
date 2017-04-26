/*
 * jQuery plugin for delayed window resize event.
 * It works similar to original jQuery resize but has additional parameter - resize_timeout.
 * It executes resize_callback with resize_timeout delay, so resize_callback wont be executed immediately when original resize event occured.
 *
 * Usage:
 *  $('some selector').resize_delayed(function() {
 *    // This is resize callback code
 *  }, resize_timeout_in_milliseconds);
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
    resize_delayed: function(resize_callback, resize_delay) {
      return this.each(function() {
        var resize_timer = null;
        $(this).resize(function() {
          if (resize_timer) {
            clearInterval(resize_timer);
          }
          resize_timer = setInterval(resize, resize_delay);
        });

        function resize() {
          resize_callback();
          clearInterval(resize_timer);
          resize_timer = null;
        }
      });
    }
  });
})(jQuery);
