$('.slide > .screenshots').live('ajax:success cache:success', function(e) {
  if ('mutex' in arguments.callee) {
    return;
  }
  arguments.callee.mutex = true;

  $('.images-list a', this).fancybox($.galleryOptions);
});
