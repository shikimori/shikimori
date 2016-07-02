class VideoExtractor::SmotretAnimeExtractor < VideoExtractor::BaseExtractor
  URL_REGEX = VideoExtractor::UrlExtractor::SMOTRET_ANIME_REGEXP

  def image_url
    parsed_data[:image_url]
  end

  def player_url
    parsed_data[:player_url]
  end

  def hosting
    parsed_data[:hosting]
  end

  def parsed_data
    {
      image_url: nil,
      player_url: Url.new(VideoExtractor::UrlExtractor.call(url)).with_http.to_s,
      hosting: :smotret_anime
    }
  end
end
