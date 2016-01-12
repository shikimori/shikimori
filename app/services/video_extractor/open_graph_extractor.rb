class VideoExtractor::OpenGraphExtractor < VideoExtractor::BaseExtractor
  PARAMS_REGEXP = /(?:\?[\w=+%&]+)?/
  URL_REGEX = %r{
    https?://(?:www\.)?(
      (?<hosting>coub).com/view/[\wА-я_-]+#{PARAMS_REGEXP.source} |
      (?:\w+\.)?(?<hosting>twitch).tv/[\wА-я_-]+/[\wА-я_-]+/[\wА-я_-]+#{PARAMS_REGEXP.source} |
      (?<hosting>rutube).ru/video/[\wА-я_-]+#{PARAMS_REGEXP.source} |
      (?<hosting>vimeo).com/[\wА-я_-]+#{PARAMS_REGEXP.source} |
      (?:\w+\.)?(?<hosting>myvi).ru/watch/[\wА-я_-]+#{PARAMS_REGEXP.source} |
      video.(?<hosting>sibnet).ru/video[\wА-я_-]+#{PARAMS_REGEXP.source} |
      #video.(?<hosting>yandex).ru/users/[\wА-я_-]+/view/[\wА-я_-]+#{PARAMS_REGEXP.source} |
      (?<hosting>dailymotion).com/video/[\wА-я_-]+#{PARAMS_REGEXP.source}
    )
  }xi

  RUTUBE_SRC_REGEX = %r{
    //rutube.ru/play/embed/(\d+)
  }xi

  def image_url
    parsed_data.first
  end

  def player_url
    parsed_data.second
  end

  def hosting
    url.match(URL_REGEX) && $~[:hosting].to_sym
  end

  def parse_data html
    doc = Nokogiri::HTML html

    og_image = doc.css("meta[property='og:image']").first
    og_video = doc.css("meta[property='og:video'],meta[property='og:video:url']").first

    [og_image[:content], og_video[:content]] if og_image && og_video
  end
end
