class VideoExtractor::UrlExtractor < ServiceObjectBase
  HTTP = %r{(?:https?:)?//(?:www\.)?}.source
  CONTENT = /[^" ><\n]+/.source
  PARAM = %r{[^" ><&?\n\/]+}.source
  SMOTRET_ANIME_REGEXP = %r{
    #{HTTP}smotret-anime.ru
      (?:
        /catalog/[\w-]+/[\w-]+/[\w-]+?-(?<id>\d+)
        |
        /translations/embed/(?<id>\d+)
      )
  }mix
  SOVET_ROMANTICA_REGEXP = %r{
    #{HTTP}sovetromantica.com
      (?:
        /embed/episode_(?<anime_id>\d+)_(?<id>\d+-\w+)
        |
        /anime/(?<anime_id>\d+)[\w-]+
          /episode_(?<id>\d+-\w+)
      )
  }mix

  RUTUBE_HASH_REGEXP = %r{
    #{HTTP}
      (?: video\. )?
      rutube\.ru
      (?:
        ( /player\.swf | /tracks/#{PARAM}\.html | / )
        \? (?: hash|v ) = (?<hash>#{PARAM})
          |
        (?: /video )? / (?<hash>#{PARAM}) /? (?:$|"|'|>)
      )
  }mix
  RUTUBE_EMBED_REGEXP = %r{
    #{HTTP}
      (video\.)?rutube.ru

      (?:
        (?: /embed | /video/embed | /play/embed )
        / (?<id> \w+ )
          |
        / embed
        /\?v= (?<id> \w+ )
      )
  }mix
  ANIMEDIA_REGEXP = %r{
    (?<url>
      #{HTTP}online.animedia.tv
        /embed
        (?:/#{PARAM})+
    )
  }mix
  ANIMAUNT_REGEXP = %r{
    (?<url>
      #{HTTP}online.animaunt.ru
        /.*\.mp4
    )
  }mix

  pattr_initialize :content

  def call
    if parsed_url
      fixed_url = parsed_url
        .gsub('&amp;', '&')
        .sub(%r{[\]\[=\\]+$}, '')
        .sub(%r{\|.*}, '')

      Url.new(fixed_url).without_protocol.to_s
    else
      data = VideoExtractor.fetch url
      data.player_url if data
    end
  end

private

  def url
    @url ||= @content.to_s.strip
  end

  def html
    @hmtl ||= if url =~ %r{^https?://[^ <>"]+$}
      "src=\"#{url}\""
    else
      url
    end
  end

  # rubocop:disable AbcSize
  # rubocop:disable MethodLength
  # rubocop:disable LineLenghth
  def parsed_url
    if html =~ %r{(?<url>#{HTTP}(?:vk.com|vkontakte.ru)/video_ext#{CONTENT})}
      cleanup_params $LAST_MATCH_INFO[:url], %w(oid id hash)
    elsif html =~ %r{#{HTTP}myvi.(ru|tv)/(#{CONTENT}/)+(preloader.swf\?id=)?(?<hash>#{CONTENT})}
      "http://myvi.ru/player/embed/html/#{$LAST_MATCH_INFO[:hash]}"
    elsif html =~ %r{(?<url>#{HTTP}(api.video|videoapi.my).mail.ru/videos#{CONTENT})}
      $LAST_MATCH_INFO[:url].gsub('api.video', 'videoapi.my')
    elsif html =~ %r{(?<url>#{HTTP}img.mail.ru/r/video2/player_v2.swf\?#{CONTENT})}
      $LAST_MATCH_INFO[:url]
    elsif html =~ %r{(#{HTTP}my.mail.ru/mail/(?<user>#{PARAM})/video/(?<ids>#{PARAM}/#{PARAM}).html)}
      "https://videoapi.my.mail.ru/videos/embed/mail/#{$~[:user]}/#{$~[:ids]}.html"
    elsif html =~ /movieSrc=(#{CONTENT})"/
      "http://videoapi.my.mail.ru/videos/embed/#{$1.sub(/&autoplay=\d/, '')}.html"
    elsif html =~ %r{(?<url>#{HTTP}video.sibnet.ru/shell#{CONTENT})}
      cleanup_params(
        $LAST_MATCH_INFO[:url].sub(/shell\.swf\?/, 'shell.php?'),
        %w(videoid)
      )
    elsif html =~ %r{#{HTTP}data\d+\.video.sibnet.ru/\d+/\d+(?:/\d+)?/(#{CONTENT}).(?:mp4|flv)}
      "http://video.sibnet.ru/shell.php?videoid=#{$1.sub(/\.(flv|mp4)\?.*/, '')}"
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
    elsif html =~ /(?<url>#{HTTP}vidbull.com#{CONTENT})/
      $LAST_MATCH_INFO[:url]
    elsif html =~ /(?<url>#{HTTP}mipix.eu#{CONTENT})/
      $LAST_MATCH_INFO[:url]
    elsif html =~ SMOTRET_ANIME_REGEXP
      "https://smotret-anime.ru/translations/embed/#{$LAST_MATCH_INFO[:id]}"
    elsif html =~ RUTUBE_HASH_REGEXP
      "http://rutube.ru/play/embed/#{$LAST_MATCH_INFO[:hash]}"
    elsif html =~ RUTUBE_EMBED_REGEXP
      "http://rutube.ru/play/embed/#{$LAST_MATCH_INFO[:id]}"
    elsif html =~ VideoExtractor::OpenGraphExtractor::RUTUBE_SRC_REGEX
      "http://rutube.ru/play/embed/#{$LAST_MATCH_INFO[:hash]}"
    elsif html =~ %r{#{HTTP}play.aniland.org/(?<hash>\w+)}
      "http://play.aniland.org/#{$LAST_MATCH_INFO[:hash]}?player=8"
    elsif html =~ SOVET_ROMANTICA_REGEXP
      'https://sovetromantica.com/embed/episode_'\
        "#{$LAST_MATCH_INFO[:anime_id]}_#{$LAST_MATCH_INFO[:id]}"
    elsif html =~ ANIMEDIA_REGEXP
      "#{$LAST_MATCH_INFO[:url]}"
    elsif html =~ ANIMAUNT_REGEXP
      "#{$LAST_MATCH_INFO[:url]}"
    else
      puts "can't extract video url: '#{html}'" unless Rails.env.test?
      nil
    end
  end
  # rubocop:enable LineLenghth
  # rubocop:enable MethodLength
  # rubocop:enable AbcSize

  def cleanup_params url, allowed_params
    url
      .gsub('&amp;', '&')
      .gsub(/[?&](?<param>[^=]+)$/, '')
      .gsub(/[?&](?<param>[^=]+)=[^&]*/) do |match|
        allowed_params.include?($LAST_MATCH_INFO[:param]) ? match : ''
      end
  end
end
