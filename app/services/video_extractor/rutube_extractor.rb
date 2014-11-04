class VideoExtractor::RutubeExtractor < VideoExtractor::BaseExtractor
  URL_REGEX = %r{
    https?://rutube.ru/video/(.*)
  }xi

  SRC_REGEX = %r{
    //rutube.ru/play/embed/(\d+)
  }xi

  def image_url
  end

  def player_url
    "http://rutube.ru/play/embed/#{parsed_data[:hash_url]}"
  end

  def parse_data html
    match_data = html.match(SRC_REGEX)
    { hash_url: match_data[1] } if match_data
  end
end
