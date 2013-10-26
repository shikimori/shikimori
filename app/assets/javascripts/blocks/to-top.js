(function() {
  if ($(window).width() <= $('.page-inner').width() + 100) {
    return;
  }
  var scroll_lock = false;
  var to_top_visible = false;
  var $to_top = $('.to-top');

  var process = function() {
    scroll_lock = false;

    if ($(this).scrollTop() !== 0) {
      if (!to_top_visible) {
        $to_top.fadeIn();
        to_top_visible = true;
      }
    } else {
      if (to_top_visible) {
        $to_top.fadeOut();
        to_top_visible = false;
      }
    }
  };

  $(window).scroll(function() {
    if (scroll_lock) {
      return;
    }
    scroll_lock = true;

    _.delay(process, 500);
  });

  $to_top.on('click', function() {
    $to_top.fadeOut();
    $('body,html').animate({scrollTop:0}, 50);
  });
})();
