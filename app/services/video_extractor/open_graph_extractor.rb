class VideoExtractor::OpenGraphExtractor < VideoExtractor::BaseExtractor
  PARAMS_REGEXP = /(?:\?[\w=+%&]+)?/
  URL_REGEX = %r{
    https?://(?:www\.)?(
      (?<hosting>coub).com/view/[\w_-]+#{PARAMS_REGEXP.source} |
      (?:\w+\.)?(?<hosting>twitch).tv/[\w_-]+/[\w_-]+/[\w_-]+#{PARAMS_REGEXP.source} |
      (?<hosting>rutube).ru/video/[\w_-]+#{PARAMS_REGEXP.source} |
      (?<hosting>vimeo).com/[\w_-]+#{PARAMS_REGEXP.source} |
      (?:\w+\.)?(?<hosting>myvi).ru/watch/[\w_-]+#{PARAMS_REGEXP.source} |
      video.(?<hosting>sibnet).ru/video[\w_-]+#{PARAMS_REGEXP.source} |
      video.(?<hosting>yandex).ru/users/[\w_-]+/view/[\w_-]+#{PARAMS_REGEXP.source} |
      (?<hosting>dailymotion).com/video/[\w_-]+#{PARAMS_REGEXP.source}
    )
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
    [doc.css("meta[property='og:image']").first[:content], doc.css("meta[property='og:video']").first[:content]]
  end
end
