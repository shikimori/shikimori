/*
 * cacheImage: a jQuery plugin
 *
 * cacheImage is a simple jQuery plugin for pre-caching images.  The
 * plugin can be used to eliminate flashes of unstyled content (FOUC) and
 * improve perceived page load time.  Callbacks for load, error and abort
 * events are provided.
 *
 * For usage and examples, visit:
 * http://github.com/alexrabarts/jquery-cacheimage
 *
 * Licensed under the MIT:
 * http://www.opensource.org/licenses/mit-license.php
 *
 * Copyright (c) 2008 Stateless Systems (http://statelesssystems.com)
 *
 * @author   Alex Rabarts (alexrabarts -at- gmail -dawt- com)
 * @requires jQuery v1.2 or later
 * @version  0.2.1
 */

(function ($) {
  $.extend($, {
    cacheImage: function (src, options) {
      if (typeof src === 'object') {
        $.each(src, function () {
          $.cacheImage(String(this), options);
        });

        return;
      }

      var image = new Image();

      options = options || {};

      $.each(['load', 'error', 'abort'], function () { // Callbacks
        var e = String(this);
        if (typeof options[e] === 'function') { $(image).bind(e, options[e]); }

        if (typeof options.complete === 'function') {
          $(image).bind(e, options.complete);
        }
      });

      image.src = src;

      return image;
    }
  });

  $.extend($.fn, {
    cacheImage: function (options) {
      return this.each(function () {
        $.cacheImage(this.src, options);
      });
    }
  });
})(jQuery);
