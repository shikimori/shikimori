class VideoExtractor::OpenGraphExtractor < VideoExtractor::BaseExtractor
  URL_REGEX = %r{
    https?://(?:www\.)?(
      (?<hosting>coub).com/view/[\w_-]+ |
      (?:\w+\.)?(?<hosting>twitch).tv/[\w_-]+/[\w_-]+/[\w_-]+ |
      (?<hosting>rutube).ru/video/[\w_-]+ |
      (?<hosting>vimeo).com/[\w_-]+ |
      (?:\w+\.)?(?<hosting>myvi).ru/watch/[\w_-]+ |
      video.(?<hosting>sibnet).ru/video[\w_-]+ |
      video.(?<hosting>yandex).ru/users/[\w_-]+/view/[\w_-]+ |
      (?<hosting>dailymotion).com/video/[\w_-]+
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
