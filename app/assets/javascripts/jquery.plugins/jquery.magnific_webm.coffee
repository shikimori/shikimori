import ShikiHtml5Video from 'views/application/shiki_html5_video'

NS = 'webm'

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
      new ShikiHtml5Video $video

      $video.appendTo($video_container)

      loaded = false
      $video.one 'loadedmetadata play playing canplay', ->
        return if loaded
        loaded = true
        $html.addClass 'loaded'

      $video.on 'error', ->
        $video_container.html('<p style="color: #fff;">broken video link</p>')

      @appendContent $html
      @updateStatus 'ready'
