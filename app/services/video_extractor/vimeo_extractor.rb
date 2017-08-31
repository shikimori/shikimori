class VideoExtractor::VimeoExtractor < VideoExtractor::OpenGraphExtractor
  URL_REGEX = %r{
    https?://(?:www\.)?(
      (?<hosting>vimeo).com/[\wА-я_-]+#{PARAMS_REGEXP.source}
    )
  }xi

  ID_PROPERTY = "meta[property='al:ios:url']"

  def player_url
    return unless parsed_data.second
    "//player.vimeo.com/video/#{parsed_data.second}"
  end

  def parse_data html
    doc = Nokogiri::HTML html

    og_image = doc.css(IMAGE_PROPERTIES.join(',')).first
    og_id = doc.css(ID_PROPERTY).first

    if og_image && og_id
      [og_image[:content], og_id[:content].match(%r{/videos/(?<id>\w+)})[:id]]
    end
  end
end
