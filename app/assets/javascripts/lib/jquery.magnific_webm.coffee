(($) ->
  NS = 'webm'
  VOLUME_KEY = 'video_volume'

  FRAME_HTML = '<div class="mfp-figure mfp-webm-holder mfp-image-holder">'+
    '<button title="Close (Esc)" type="button" class="mfp-close">×</button>'+
    '<figure>'+
      '<div class="mfp-img">'+
        '<div class="b-fancy_loader"></div>' +
      '</div>'+
    '</figure>'+
  '</div>'

  $.magnificPopup.registerModule NS,
    options:
      settings: null
      cursor: 'mfp-ajax-cur'

    proto:
      initWebm: ->
        @types.push NS

      getWebm: (item) ->
        $html = $(FRAME_HTML)
        $video_container = $html.find('.mfp-img')

        $video = $('<video>').attr(
          class: 'mfp-webm'
          src: item.el.data('video')
          controls: 'controls'
          autoplay: true
          #preload: 'none'
        )
        $video[0].volume = $.sessionStorage.get(VOLUME_KEY) || 1

        $video.appendTo($video_container)

        loaded = false
        $video
          .one 'loadedmetadata play playing canplay', ->
            return if loaded
            loaded = true
            $html.addClass 'loaded'

          .on 'error', (e) ->
            $video_container.html('<p style="color: #fff;">broken video link</p>')

          .on 'click', ->
            if @paused
              @play()
            else
              @pause()
            false

          .on 'volumechange', (e) ->
            $.sessionStorage.set VOLUME_KEY, @volume

        @appendContent $html
        @updateStatus 'ready'
) jQuery
