$.extend({
  galleryOptions: {
    cyclic: true,
    hideOnContentClick: true,
    transitionIn: 'elastic',
    transitionOut: 'elastic',
    speedIn: 400,
    speedOut: 200
  }
});

$.extend({
  youtubeOptions: $.extend({}, $.galleryOptions, {
    padding: 0,
    autoScale: false,
    width: 680,
    showNavArrows: false,
    hideOnContentClick: false,
    height: 495,
    type: 'swf',
    swf: {
      wmode: 'transparent',
      allowfullscreen: true
    },
    onStart() {
      $('#fancybox-expand').hide();
      return true;
    },
    onComplete() {
      $('#fancybox-expand').hide();
    }
  }
  )
});

$.extend({
  vkOptions: $.extend({}, $.youtubeOptions, { type: 'iframe' })
});
