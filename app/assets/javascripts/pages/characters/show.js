$(function() {
  // slides
  $('.slider-control').click(function(e) {
    // we should ignore middle button click
    if (in_new_tab(e)) {
      return;
    }
    $.history.load(($(this).children('a').attr('href') || $(this).children('span.link').data('href')).replace(/http:\/\/.*?\//, '/'));
    return false;
  });
  var $controls = $('.slider-control', $('.character-left-menu'));
  $('.entry-content-slider').makeSliderable({
    $controls: $controls,
    history: true,
    remote_load: true,
    easing: 'easeInOutBack',
    onslide: function($control) {
      $controls.removeClass('selected');
      $control.addClass('selected');
    }
  });

  // history
  $.history.init(function(url) {
    var no_clear = false;
    if (url === "") {
      url = location.href.replace(/http:\/\/.*?\//, '/');
      no_clear = true;
    }

    if ('first_run' in arguments.callee) {
      var map_url = location.href.replace(/(http:\/\/.*?)\/.*/, '$1') + url;
      if ('MAP' in window && map_url in MAP) {
        // т.к. мы можем ходить по истории назад, то надо сделать активной нужную галерею
        //$(_.select($('.ad-nav [data-remote]'), function(v, k) { return $(v).attr('data-remote') == map_url })[0])
        $('.ad-nav').find("[data-remote='" + map_url + "']").parent().addClass('ad-active')
                                                            .parent().siblings().find('a').removeClass('ad-active');

        var $container = $('.gallery-container');
        //$container.animate({opacity: 0.3}, function() {
          $container.find('*').unbind();
          //$container.find('.ad-nav').html(MAP[map_url].html);
          $container.find('.images-list').html(MAP[map_url].html);
          $container.find('.gallery-title').html(MAP[map_url].title);
          $container.find('.gallery-edit').attr('href', MAP[map_url].edit);
          $container.find('.ad-info').html('');
          $container.find('.ad-gallery').data('initialized', false);
          //$(this).find('.comment_body').data('ckeditorInstance').destroy();
          //var $comments = $('.cosplay-comments-container');
          //if ($comments.children('img').length == 1) {
            //$comments.data('request').abort();
          //} else {
            //$comments.html('<img src="' + ($.browser.msie || $.browser.webkit ? '/images/ajax.gif' : '/images/ajax.png') + '" style="margin: 50px auto 0 auto; display:block;" />');
          //}
          //$comments.data('request', $.ajax({
            //url: MAP[map_url].comments,
            //data: null,
            //success: function (data, status, xhr) {
              //$comments.html(data);
            //}
          //}));

          //$('.cosplay-comments-container').html('<img src="' + ($.browser.msie || $.browser.webkit ? '/images/ajax.gif' : '/images/ajax.png') + '" style="margin: 50px auto 0 auto; display:block;" />')
                                          //.load();
          //init_gallery.call($container);
          //$('.ad-gallery li img', $container).bind('load', _.bind(init_gallery, $container));
          $($container).gallery();
        //});
        return;
      } else {
        MAP = {};
      }
    } else {
      arguments.callee.first_run = true;
    }

    var $target;
    $('.slider-control a,.slider-control span.link').each(function(k, v) {
      if (url.indexOf((this.className.indexOf('link') == -1 ? this.href : $(this).data('href')).replace(/http:\/\/.*?(?=\/)/, '')) != -1) {
        $target = $(this).parent();
      }
    });
    var menu_url = ($target.children('a').attr('href') || $target.children('span.link').data('href')).replace(/http:\/\/.*?(?=\/)/, '');
    if (menu_url != url) {
      // в нужном li делается подмена урла, т.к. урл для загрузки страницы будет взят оттуда, а затем после загрузки страницы урл меняется назад
      $target.children().attr('href', url).data('href', url);
      $target.trigger('slider:click', no_clear);
      $target.children().attr('href', menu_url).data('href', menu_url);
    } else {
      $target.trigger('slider:click', no_clear);
    }
  });
});

// переход в Обсуждение по клику на комментировать
$('.actions .comment').live('click', function() {
  var editor_selector = '.comments .comments-container > .shiki-editor:first-child';
  if ($('.slide > .comments').hasClass('selected')) {
    $(editor_selector).focus();
  } else {
    $('.slide > .comments').one('ajax:success cache:success', function() {
      _.delay(function() {
        $(editor_selector).focus();
      }, 250);
    });
    $('.slider-control-comments').trigger('click');
  }
});
