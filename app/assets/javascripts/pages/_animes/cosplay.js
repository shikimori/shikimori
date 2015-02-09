function init_gallery() {
  var self = this;
  $('.ad-gallery', this).each(function(k, v) {
    var $gallery = $(this);
    if ($gallery.data('initialized')) {
      return;
    }
    var $images;
    if (!$gallery.data('images')) {
      $images = $('li img', $gallery);
      $gallery.data('images', $images);
    } else {
      $images = $gallery.data('images');
    }
    if (_.all($images.map(function(k,v) { return $(v).attr('data-loaded') == 'true'; }), function(v,k) { return v; })) {
      $gallery.data('initialized', true);
    } else {
      return;
    }
    _.defer(function() {
      var params = {
        width: 703,
        height: 600,
        slideshow: {
          start_label: '',
          stop_label: ''
        }
      };
      if ($gallery.hasClass('gallery-selector')) {
        params.start_at_index = $gallery.find('a').index($gallery.find('.ad-active'));
        if (params.start_at_index == -1) {
          delete params.start_at_index;
        }
        params.callbacks = {
          beforeImageVisible: function(index) {
            // первый раз ничего не надо делать - срабатывает при инициализации страницы
            if (!('flag' in arguments.callee)) {
              arguments.callee.flag = true;
              return;
            }
            var url = $(this.thumbs_wrapper.find('img').get(index)).attr('data-remote').replace(/http:\/\/.*?\//, '/');
            // если кликнули на ту же картинку, то ничего не делаем
            if (url == location.pathname) {
              return;
            }

            History.pushState({timestamp: Date.now()}, null, url);
          }
        };
      }
      $gallery.adGallery(params);
      $gallery.parent().parent().animate({opacity: 1});
    });
  });
}

$(function() {
  History.Adapter.bind(window, 'statechange', function() {
    var url = location.href;
    if (!('GALLERIES' in window && url in GALLERIES)) {
      return;
    }
    var $container = $('.gallery-container');
    var gallery = GALLERIES[url];

    if ($container.data('url') == url) {
      return;
    }

    // т.к. мы можем ходить по истории назад, то надо сделать активной нужную галерею
    $('.ad-nav')
      .find("[data-remote='" + url + "']")
        .parent()
        .addClass('ad-active')
          .parent().siblings().find('a')
          .removeClass('ad-active');

    $container.find('*').unbind();
    $container.data('url', url);
    $container.find('.images-list').html(gallery.html);
    $container.find('.gallery-title').html(gallery.title);
    $container.find('.gallery-edit').attr('href', gallery.edit);
    $container.find('.ad-info').html('');
    $container.find('.ad-gallery').data('initialized', false);
    $($container).gallery({no_hide: true});
  });
});

$('.slide > .cosplay').live('ajax:success cache:success', function(e) {
  $(this).gallery();

  init_gallery.call(this);
  $('.ad-gallery li img', this).bind('load', _.bind(init_gallery, this));
});
