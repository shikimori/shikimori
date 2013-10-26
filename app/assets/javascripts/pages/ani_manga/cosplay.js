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
      //$('.ad-gallery li img', self).bind('load', _.bind(init_gallery, self));
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
        //params.width = params.width - $('.gallery-cosplayers').width() - $('.gallery-characters').width() - 30;
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

            //// в нужном li делается подмена урла, т.к. урл для загрузки страницы будет взят оттуда, а затем после загрузки страницы урл меняется назад
            //$('.slider-control a').each(function(k, v) {
              //if (url.indexOf(this.href.replace(/http:\/\/.*?(?=\/)/, '')) != -1) {
                //$target = $(this);
              //}
            //});
            //var menu_url = $target.attr('href');
            //$target.attr('href', url)
            $.history.load(url);
            //$target.attr('href', menu_url)
          }
        };
      }
      $gallery.adGallery(params);
      $gallery.parent().parent().animate({opacity: 1});
    });
  });
}

$('.slide > .cosplay-all').live('ajax:success cache:success', function(e) {
  $(this).gallery();

  init_gallery.call(this);
  $('.ad-gallery li img', this).bind('load', _.bind(init_gallery, this));
}).live('ajax:clear', function(e, data) {
  // очистка контента, чтобы в следующий раз загрузился новый
  if ($.isReady) {
    $(this).append('<div class="clear-marker"></div>');
  }
  //$(this).find('.comment_body').data('ckeditorInstance').destroy();
  //MAP = {};
});
