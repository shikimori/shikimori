class VideoExtractor::OpenGraphExtractor < VideoExtractor::BaseExtractor
  PARAMS_REGEXP = /(?:\?[\w=+%&]+)?/
  # Video.hosting should include these hostings
  # shiki_video should include these hostings too
  URL_REGEX = %r{
    https?://(?:www\.)?(
      (?<hosting>coub).com/view/[\wА-я_-]+#{PARAMS_REGEXP.source} |
      (?:\w+\.)?(?<hosting>twitch).tv/[\wА-я_-]+/[\wА-я_-]+/[\wА-я_-]+#{PARAMS_REGEXP.source} |
      (?<hosting>rutube).ru/video/[\wА-я_-]+#{PARAMS_REGEXP.source} |
      (?<hosting>vimeo).com/[\wА-я_-]+#{PARAMS_REGEXP.source} |
      (?:\w+\.)?(?<hosting>myvi).ru/watch/[\wА-я_-]+#{PARAMS_REGEXP.source} |
      video.(?<hosting>sibnet).ru/video[\wА-я_-]+#{PARAMS_REGEXP.source} |
      #video.(?<hosting>yandex).ru/users/[\wА-я_-]+/view/[\wА-я_-]+#{PARAMS_REGEXP.source} |
      (?<hosting>dailymotion).com/video/[\wА-я_-]+#{PARAMS_REGEXP.source} |
      (?<hosting>streamable).com/[\wА-я_-]+#{PARAMS_REGEXP.source}
    )
  }xi

  RUTUBE_SRC_REGEX = %r{
    //rutube.ru/play/embed/(\d+)
  }xi


  IMAGE_PROPERTIES = %w(
    meta[property='og:image']
  )

  # twitter:player - for dailymotion
  VIDEO_PROPERTIES = %w(
    meta[name='twitter:player']
    meta[property='og:video']
    meta[property='og:video:url']
  )

  SHIT_HOSTINGS = %i( vimeo )

  def image_url
    if SHIT_HOSTINGS.include? hosting
      parsed_data.first
    else
      parsed_data.first&.without_protocol
    end
  end

  def player_url
    if SHIT_HOSTINGS.include? hosting
      parsed_data.second
    else
      parsed_data.second&.without_protocol
    end
  end

  def hosting
    url.match(URL_REGEX) && $~[:hosting].to_sym
  end

  def parse_data html
    doc = Nokogiri::HTML html

    og_image = doc.css(IMAGE_PROPERTIES.join ',').first
    og_video = VIDEO_PROPERTIES.map { |v| doc.css(v).first }.find(&:present?)

    if og_image && og_video
      [og_image[:content], og_video[:content] || og_video[:value]]
    end
  end
end
