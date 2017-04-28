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

  $.extend
    vkOptions: $.extend({}, $.youtubeOptions,
        type: 'iframe'
      )

  resize_binded = false

  # дефолтная галерея сайта
  $.fn.extend gallery: (options={}) ->
    @each ->
      $container = $('.container', @)
      $images = $('.b-image', $container).shiki_image()

      $container.imagesLoaded ->
        $container.addClass('packery')
        $container.packery
          columnWidth: '.grid_sizer'
          containerStyle: null
          gutter: 0
          isAnimated: false
          isResizeBound: false
          itemSelector: '.b-image'
          transitionDuration: if options.imageboard then 0 else '0.25s'

      if options.shiki_upload
        $container
          .shikiFile
            progress: $container.prev()

          .on 'upload:success', (e, response) ->
            return if options.shiki_upload_custom

            $image = $(response.html)
            $container.prepend($image)
            delay(50).then -> $container.packery('prepended', $image)
            $image.shiki_image()

      unless resize_binded
        resize_binded = true
        $(window).resize_delayed ->
          $galleries = $('.packery')
          $galleries.packery()
          delay(1250).then -> $galleries.packery()
        , 500

) jQuery
