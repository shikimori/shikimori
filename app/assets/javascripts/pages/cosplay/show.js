$(function() {
  init_gallery();
  $('.ad-gallery li img').bind('load', init_gallery);
});

function init_gallery() {
  if ('initialized' in arguments.callee) {
    return;
  }
  if (!('mutex' in arguments.callee)) {
    var $images = arguments.callee.$images = $('.ad-gallery li img');
  } else {
    var $images = arguments.callee.$images;
  }
  if (_.all($images, function(v,k) { return $(v).attr('data-loaded') == 'true' })) {
    arguments.callee.initialized = true;
  } else {
    return;
  }
  _.defer(function() {
    $('.ad-gallery').adGallery({
      width: 685,
      height: 600,
      slideshow: {
        start_label: '',
        stop_label: ''
      }
    });
  });
}

