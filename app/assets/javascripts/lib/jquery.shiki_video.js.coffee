(($) ->
  video_hosting = (domain, $root) ->
    index: "#{domain}/"
    src: '%id%'
    id: (url) -> $root.data('href')

  video_hostings = ($root) ->
    youtube: video_hosting('youtube.com', $root)
    vimeo: video_hosting('vimeo.com', $root)
    youtu_be: video_hosting('youtu.be', $root)
    rutube_ru: video_hosting('rutube.ru', $root)
    vk_com: video_hosting('vk.com', $root)
    vkontakte_ru: video_hosting('vkontakte.ru', $root)
    coub_com: video_hosting('coub.com', $root)
    twitch_rv: video_hosting('twitch.tv', $root)
    rutube_ru: video_hosting('rutube.ru', $root)
    myvi_ru: video_hosting('myvi.ru', $root)
    sibnet: video_hosting('sibnet.ru', $root)
    yandex_ru: video_hosting('yandex.ru', $root)
    dailymotion_com: video_hosting('dailymotion.com', $root)

    #youtube_example:
      #index: 'youtube.com' # String that detects type of video (in this case YouTube). Simply via url.indexOf(index).
      #id: 'v=' # String that splits URL in a two parts, second part should be %id%
      # Or null - full URL will be returned
      # Or a function that should return %id%, for example:
      # id: function(url) { return 'parsed id'; }
      #src: '//www.youtube.com/embed/%id%?autoplay=1' # URL that will be set as a source for iframe.

  $.fn.extend
    shiki_video: ->
      @each ->
        $root = $(@)
        return unless $root.hasClass('unprocessed')
        $root.removeClass('unprocessed')

        $root.magnificPopup
          preloader: false
          type: 'iframe'
          iframe:
            markup: '<div class="mfp-iframe-scaler">'+
                      '<div class="mfp-close"></div>'+
                      '<iframe class="mfp-iframe" frameborder="0" allowfullscreen></iframe>'+
                    '</div>', # HTML markup of popup, `mfp-close` will be replaced by the close button

            srcAction: 'iframe_src', # Templating object key. First part defines CSS selector, second attribute. "iframe_src" means: find "iframe" and set attribute "src".
            patterns: video_hostings($root)
) jQuery
