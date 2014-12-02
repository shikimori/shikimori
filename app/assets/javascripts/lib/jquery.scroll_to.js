(function($){
  $.extend({
    scrollTo: function(marker, animation) {
      if (typeof marker == "number") {
        var top = marker;
      } else {
        var $marker = $(marker);
        if ($marker.length) {
          var top = $marker.offset().top - 10;
        } else {
          var top = 0;
        }
      }
      $('html, body').animate({scrollTop: top}, 250, animation || 'easeInOutCirc'); // easeInOutCirc // easeOutElastic
    }
  });
})(jQuery);
