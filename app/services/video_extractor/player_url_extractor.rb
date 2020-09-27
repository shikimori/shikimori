class VideoExtractor::PlayerUrlExtractor < ServiceObjectBase
  HTTP = %r{(?:https?:)?//(?:www\.)?}.source
  CONTENT = /[^" ><\n]+/.source
  PARAM = %r{[^" ><&?\n\/]+}.source
  # SMOTRET_ANIME_REGEXP = %r{
  #   #{HTTP}smotretanime.ru
  #     (?:
  #       /catalog/[\w-]+/[\w-]+/[\w-]+?-(?<id>\d+)
  #       |
  #       /translations/embed/(?<id>\d+)
  #     )
  # }mix
  # SOVET_ROMANTICA_REGEXP = %r{
  #   #{HTTP}sovetromantica.com
  #     (?:
  #       /embed/episode_(?<anime_id>\d+)_(?<id>\d+-\w+)
  #       |
  #       /anime/(?<anime_id>\d+)[\w-]+
  #         /episode_(?<id>\d+-\w+)
  #     )
  # }mix

  # ANIMEDIA_REGEXP = %r{
  #   (?<url>
  #     #{HTTP}online.animedia.tv
  #       /embed
  #       (?:/#{PARAM})+
  #   )
  # }mix
  # ANIMAUNT_REGEXP = %r{
  #   (?<url>
  #     #{HTTP}online.animaunt.ru
  #       /.*\.mp4
  #   )
  # }mix

  pattr_initialize :content

  def call
    player_url = parsed_url || extracted_url
    Url.new(player_url).without_protocol.to_s if player_url
  end

private

  def parsed_url
    parse_url
      &.gsub('&amp;', '&')
      &.sub(/[\]\[=\\]+$/, '')
      &.sub(/\|.*/, '')
  end

  def extracted_url
    data = VideoExtractor.fetch url
    data&.player_url
  end

  def url
    @url ||= @content.to_s.strip
  end

  def html
    @html ||=
      if %r{^https?://[^ <>"]+$}.match?(url)
        "src=\"#{url}\""
      else
        url
      end
  end

  def parse_url # rubocop:disable all
    if html =~ %r{(?<url>#{HTTP}(?:vk.com|vkontakte.ru)/video_ext#{CONTENT})}
      cleanup_params(
        VideoExtractor::VkExtractor.normalize_url($LAST_MATCH_INFO[:url]),
        %w[oid id hash]
      )
    # elsif html =~ %r{#{HTTP}myvi.(ru|tv)/(#{CONTENT}/)+(preloader.swf\?id=)?(?<hash>#{CONTENT})}
      # "http://myvi.ru/player/embed/html/#{$LAST_MATCH_INFO[:hash]}"
    elsif html =~ %r{#{HTTP}(?:www.)?myvi.(?:top|tv)/embed/(?<hash>#{CONTENT})}
      "https://www.myvi.top/embed/#{$LAST_MATCH_INFO[:hash]}"
    elsif html =~ %r{(?<url>#{HTTP}(api.video|videoapi.my).mail.ru/videos#{CONTENT})}
      $LAST_MATCH_INFO[:url].gsub('api.video', 'videoapi.my')
    elsif html =~ %r{(?<url>#{HTTP}img.mail.ru/r/video2/player_v2.swf\?#{CONTENT})}
      $LAST_MATCH_INFO[:url]
    elsif html =~ %r{(#{HTTP}my.mail.ru/mail/(?<user>#{PARAM})/video/(?<ids>#{PARAM}/#{PARAM}).html)}
      "https://videoapi.my.mail.ru/videos/embed/mail/#{$LAST_MATCH_INFO[:user]}/#{$LAST_MATCH_INFO[:ids]}.html"
    elsif html =~ /movieSrc=(#{CONTENT})"/
      "https://videoapi.my.mail.ru/videos/embed/#{Regexp.last_match(1).sub(/&autoplay=\d/, '')}.html"
    elsif html =~ %r{(?<url>#{HTTP}video.sibnet.ru/shell#{CONTENT})}
      cleanup_params(
        $LAST_MATCH_INFO[:url].sub(/shell\.swf\?/, 'shell.php?'),
        %w[videoid]
      ).gsub(/(videoid=\d+)[\w\.]*/, '\1')
    elsif html =~ %r{#{HTTP}data\d+\.video.sibnet.ru/\d+/\d+(?:/\d+)?/(?<videoid>#{CONTENT}).(?:mp4|flv)}
      video_id = $LAST_MATCH_INFO[:videoid]
        .sub(/\.(flv|mp4)\?.*/, '')
        .gsub(/(videoid=\d+)[\w\.]*/, '\1')
      "https://video.sibnet.ru/shell.php?videoid=#{video_id}"
    elsif html =~ %r{(?<url>#{HTTP}video.sibnet.ru/\w+/\w+/video(?<videoid>\d+)#{CONTENT})}
      "https://video.sibnet.ru/shell.php?videoid=#{$LAST_MATCH_INFO[:videoid]}"
    elsif html =~ %r{(?<url>#{HTTP}v.kiwi.\w+/(?:v|v2)/#{CONTENT})}
      $LAST_MATCH_INFO[:url]
    elsif html =~ %r{(?<url>#{HTTP}p.kiwi.\w+/static/player2/player.swf\?config=#{CONTENT})}
      $LAST_MATCH_INFO[:url]
    elsif html =~ VideoExtractor::YoutubeExtractor::URL_REGEX
      "//youtube.com/embed/#{$LAST_MATCH_INFO[:key]}"
    elsif html =~ %r{(?<url>#{HTTP}i.i.ua/video/evp.swf\?#{CONTENT})}
      $LAST_MATCH_INFO[:url]
    elsif html =~ /(?<url>#{HTTP}video.yandex.ru#{CONTENT})/
      $LAST_MATCH_INFO[:url]
    elsif html =~ /(?<url>#{HTTP}flashx.tv#{CONTENT})/
      $LAST_MATCH_INFO[:url]
    # elsif html =~ %r{(?<url>#{HTTP}video.youmite.ru/embed/#{CONTENT})}
    #   $LAST_MATCH_INFO[:url]
    elsif html =~ /(?<url>#{HTTP}vidbull.com#{CONTENT})/
      $LAST_MATCH_INFO[:url]
    elsif html =~ %r{(?<url>#{HTTP}(?:www\.)?mp4upload.com/embed-#{CONTENT}.html)}
      $LAST_MATCH_INFO[:url].gsub('www.mp4upload.com', 'mp4upload.com')
    elsif html =~ /(?<url>#{HTTP}mipix.eu#{CONTENT})/
      $LAST_MATCH_INFO[:url]
    # elsif html =~ %r{(?<url>#{HTTP}viuly.io/embed/#{CONTENT})}
    #   $LAST_MATCH_INFO[:url]
    # elsif html =~ %r{(?<url>#{HTTP}stormo.(?:xyz|tv)/embed/#{CONTENT})}
    #   $LAST_MATCH_INFO[:url]
    elsif html =~ %r{#{HTTP}(?:zedfilm|gidfilm).ru(?:/embed)?/(?<id>#{CONTENT})}
      "https://gidfilm.ru/embed/#{$LAST_MATCH_INFO[:id]}"
    elsif html =~ %r{(?<url>#{HTTP}wikianime.tv/embed/\?id=#{CONTENT})}
      $LAST_MATCH_INFO[:url]
    # elsif html =~ %r{#{HTTP}(?:mediafile.online|iframedream.com)/embed/(?<id>#{CONTENT})}
    #   "https://mediafile.online/embed/#{$LAST_MATCH_INFO[:id]}"
    # elsif html =~ SMOTRET_ANIME_REGEXP
    #   "https://smotretanime.ru/translations/embed/#{$LAST_MATCH_INFO[:id]}"
    # elsif html =~ VideoExtractor::RutubeExtractor::URL_REGEX
    #   if $LAST_MATCH_INFO[:hash].size > 10
    #     format(
    #       VideoExtractor::RutubeExtractor::URL_TEMPLATE,
    #       $LAST_MATCH_INFO[:hash]
    #     )
    #   end
    #   # else - result will be given by VideoExtractor::RutubeExtractor
    # elsif html =~ %r{#{HTTP}play.aniland.org/(?<hash>\w+)}
      # "https://play.aniland.org/#{$LAST_MATCH_INFO[:hash]}?player=8"
    # elsif html =~ SOVET_ROMANTICA_REGEXP
    #   'https://sovetromantica.com/embed/episode_'\
    #     "#{$LAST_MATCH_INFO[:anime_id]}_#{$LAST_MATCH_INFO[:id]}"
    #       .gsub(/-d.*/, '-dubbed')
    #       .gsub(/-s.*/, '-subtitles')
    # elsif html =~ ANIMEDIA_REGEXP
    #   ($LAST_MATCH_INFO[:url]).to_s.gsub(/-.*/, '')
    # elsif html =~ ANIMAUNT_REGEXP
    #   ($LAST_MATCH_INFO[:url]).to_s
    elsif html =~ VideoExtractor::OkExtractor::URL_REGEX
      "https://ok.ru/videoembed/#{$LAST_MATCH_INFO[:key]}"
    else
      puts "can't extract video url: '#{html}'" unless Rails.env.test?
      nil
    end
  end

  def cleanup_params url, allowed_params
    VideoExtractor::CleanupParams.call url, allowed_params
  end
end
