class VideoExtractor::VimeoExtractor < VideoExtractor::OpenGraphExtractor
  OPEN_URI_OPTIONS = VideoExtractor::OpenGraphExtractor::OPEN_URI_OPTIONS.merge(
    **Proxy.prepaid_proxy
  )

  URL_REGEX = %r{
    https?://(?:www\.)?(
      (?<hosting>vimeo).com/[\wА-я_-]+#{PARAMS}
    )
  }xi

  ID_PROPERTY = "meta[property='al:ios:url']"
  ID_REGEXP = %r{
    /videos/(?<id>\w+)
    |
    \A vimeo://(?<id>\w+) \Z
  }mix

  def player_url
    return unless parsed_data.second

    "//player.vimeo.com/video/#{parsed_data.second}"
  end

  def parse_data html
    doc = Nokogiri::HTML html

    og_image = doc.css(IMAGE_PROPERTIES.join(',')).first
    og_id = doc.css(ID_PROPERTY).first

    if og_image && og_id && og_id[:content] =~ ID_REGEXP
      [og_image[:content], $LAST_MATCH_INFO[:id]]
    end
  end
end
