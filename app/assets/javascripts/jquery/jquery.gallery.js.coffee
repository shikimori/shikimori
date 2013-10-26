(($) ->
  $.extend
    galleryOptions:
      cyclic: true
      hideOnContentClick: true
      transitionIn: 'elastic'
      transitionOut: 'elastic'
      speedIn: 400
      speedOut: 200

  $.extend
    youtubeOptions: $.extend({}, $.galleryOptions,
        padding: 0
        autoScale: false
        width: 680
        showNavArrows: false
        hideOnContentClick: false
        height: 495
        type: 'swf'
        swf:
          wmode: 'transparent'
          allowfullscreen: true
        onStart: ->
          $('#fancybox-expand').hide()
          true
        onComplete: ->
          $('#fancybox-expand').hide()
      )

  # дефолтная галерея сайта
  $.fn.extend gallery: (options) ->
    @each ->
      $list = $('.images-list', @)
      $('a', $list).fancybox $.galleryOptions
      $images_to_load = $('.image-container.preload', $list)
      $images_to_load.hide() if options && !options.no_hide

      $($list).imagesLoaded ->
        _.delay ->
          if $list.hasClass('masonry')
            $list.masonry 'reload'
          else
            param = $.merge options || {},
              itemSelector: '.image-container'
              isAnimated: not Modernizr.csstransitions
            $list.masonry param

          options['onMason']() if options && 'onMason' of options
          $images_to_load.show().removeClass 'preload'
) jQuery
