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
          autoplay: true
          #preload: 'none'
        )

        $frame = $('<div class="mfp-figure mfp-image-holder">'+
            '<button title="Close (Esc)" type="button" class="mfp-close">×</button>'+
            '<figure>'+
              '<div class="mfp-img"></div>'+
            '</figure>'+
          '</div>')
        $video_container = $frame.find('.mfp-img')

        $close = $frame.find('.mfp-close').hide()
        $loading = $("<div class='b-fancy_loader' />").appendTo($video_container)
        loaded = false

        $video
          .one 'loadedmetadata play playing canplay', ->
            return if loaded

            $close.show()
            $video_container
              .empty()
              .append($video)
            loaded = true

          .on 'error', (e) ->
            $video_container
              .empty()
              .append('<p style="color: #fff;">broken video link</p>')

          .on 'click', ->
            if @paused
              @play()
            else
              @pause()
            false

        @appendContent $frame

        @updateStatus 'ready'
) jQuery
