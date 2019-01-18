video_hosting = (domain, href) ->
  index: "#{domain}/"
  src: '%id%'
  id: (url) -> href

video_hostings = ($link) ->
  url = $link.data('href')

  youtube: video_hosting('youtube.com', url)
  vimeo: video_hosting('vimeo.com', url)
  youtu_be: video_hosting('youtu.be', url)
  rutube_ru: video_hosting('rutube.ru', url)
  vk_com: video_hosting('vk.com', url)
  vkontakte_ru: video_hosting('vkontakte.ru', url)
  coub_com: video_hosting('coub.com', url)
  twitch_rv: video_hosting('twitch.tv', url)
  myvi_ru: video_hosting('myvi.ru', url)
  myvi_top: video_hosting('myvi.top', url)
  sibnet: video_hosting('sibnet.ru', url)
  yandex_ru: video_hosting('yandex.ru', url)
  dailymotion_com: video_hosting('dailymotion.com', url)
  streamable_com: video_hosting('streamable.com', url)
  smotret_anime: video_hosting('smotretanime.ru', url)
  ok_ru: video_hosting('ok.ru', url)

  # youtube_example:
  #   index: 'youtube.com' # String that detects type of video (in this case YouTube). Simply via url.indexOf(index).
  #   id: 'v=' # String that splits URL in a two parts, second part should be %id%
  #   Or null - full URL will be returned
  #   Or a function that should return %id%, for example:
  #   id: function(url) { return 'parsed id'; }
  #   src: '//www.youtube.com/embed/%id%?autoplay=1' # URL that will be set as a source for iframe.

$.fn.extend
  shikiVideo: ->
    @each ->
      $root = $(@)
      return unless $root.hasClass('unprocessed')
      $root.removeClass('unprocessed')

      $link = $root.find('.video-link')

      $link.magnificPopup
        preloader: false
        type: 'iframe'
        iframe:
          # HTML markup of popup, `mfp-close` will be replaced by the close button
          markup: '<div class="mfp-iframe-scaler">'+
                    '<div class="mfp-close"></div>'+
                    '<iframe class="mfp-iframe" frameborder="0" allowfullscreen></iframe>'+
                  '</div>'

          # Templating object key. First part defines CSS selector, second attribute.
          # "iframe_src" means: find "iframe" and set attribute "src".
          srcAction: 'iframe_src'
          patterns: video_hostings($link)

      if $root.hasClass('youtube') || $root.hasClass('vk')
        $poster = $root.find('img')
        $poster.imagesLoaded ->
          if ($poster[0].naturalWidth * 1.0 / $poster[0].naturalHeight).round(1) == 1.3
            $root.addClass 'shrinked'
