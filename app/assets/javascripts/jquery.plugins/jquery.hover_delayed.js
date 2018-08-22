/*
 * jQuery plugin for delayed hover mouse_out event.
 * It works similar to original jQuery hover but has additional parameter - mouse_out_timeout.
 * It executes mouseOutCallback with mouse_out_timeout delay, so mouseOutCallback wont be executed when mouse cursor quickly returned to hoverable area.
 *
 * Usage:
 *  $('some selector').hoverDelayed(function() {
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
$.fn.extend({
  hoverDelayed(mouseOverCallback, mouseOutCallback, mouseOverDelay, mouseOutDelay) {
    return this.each(function () {
      let overTimer = null;
      let outTimer = null;

      $(this).hover(
        function (e) {
          if (outTimer) {
            clearInterval(outTimer);
            outTimer = null;
          }
          if (!overTimer) {
            const _this = this;
            overTimer = setInterval(() => {
              over.call(_this, e);
            }, mouseOverDelay);
          }
        },
        function (e) {
          if (overTimer) {
            clearInterval(overTimer);
            overTimer = null;
          }
          if (!outTimer) {
            const _this = this;
            outTimer = setInterval(() => {
              out.call(_this, e);
            }, mouseOutDelay);
          }
        }
      );

      function over(e) {
        mouseOverCallback.call(this, e);
        clearInterval(overTimer);
        overTimer = null;
      }

      function out(e) {
        mouseOutCallback.call(this, e);
        clearInterval(outTimer);
        outTimer = null;
      }
    });
  }
});
