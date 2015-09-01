(($) ->
  NS = 'webm'

  $.magnificPopup.registerModule NS,
    options:
      settings: null
      cursor: 'mfp-ajax-cur'

    proto:
      initWebm: ->
        @types.push NS

      getWebm: (item) ->
        $video = $("<video>").attr(
          class: 'mfp-webm'
          src: item.el.data('video')
          controls: 'controls'
          #autoplay: false
          #preload: 'none'
        )

        $frame = $('<div class="mfp-figure mfp-image-holder">'+
            '<button title="Close (Esc)" type="button" class="mfp-close">×</button>'+
            '<figure>'+
              '<div class="mfp-img"></div>'+
            '</figure>'+
          '</div>')

        $close = $frame.find('.mfp-close').hide()
        $loading = $("<div class='b-fancy_loader' />").appendTo($frame.find('.mfp-img'))

        $video
          .on 'loadedmetadata', ->
            $loading.remove()
            $video.appendTo($frame.find('.mfp-img'))
            $close.show()

          .on 'click', ->
            if @paused
              @play()
            else
              @pause()
            false

        @appendContent $frame

        @updateStatus 'ready'
) jQuery
