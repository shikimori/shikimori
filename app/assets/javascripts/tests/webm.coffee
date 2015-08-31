NS = 'webm'

$.magnificPopup.registerModule NS,
  options:
    settings: null
    cursor: 'mfp-ajax-cur'

  proto:
    initWebm: ->
      @types.push NS
      #_mfpOn CLOSE_EVENT + '.' + NS, _destroyAjaxRequest
      #_mfpOn 'BeforeChange.' + NS, _destroyAjaxRequest

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

      $video
        .appendTo($frame.find('.mfp-img'))
        .on 'click', ->
          if @paused
            @play()
          else
            @pause()
          false

      @appendContent $frame

      #@_parseMarkup(template, dataObj, item);
      @updateStatus('ready')


$ ->
  $('.webm').magnificPopup
    preloader: false
    type: 'webm'
    mainClass: 'mfp-no-margins mfp-img-mobile'
    closeOnContentClick: true
