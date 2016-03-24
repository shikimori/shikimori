class VideoExtractor::VkExtractor < VideoExtractor::BaseExtractor
  URL_REGEX = %r{
    https?://vk.com/video-?(\d+)_(\d+)(?:\?[\w=+%&]+)?
  }xi

  def image_url
    parsed_data[:image]&.without_protocol
  end

  def player_url
    "//vk.com/video_ext.php?oid=#{parsed_data[:oid]}&id=#{parsed_data[:vid]}&hash=#{parsed_data[:hash2]}"
  end

  def parse_data html
    doc = Nokogiri::HTML html

    og_image = doc.css("meta[property='og:image']").first
    og_video = doc.css("meta[property='og:video'],meta[property='og:video:url']").first

    {
      image: og_image[:content],
      oid: og_video[:content][/oid=([-\w]+)/, 1],
      vid: og_video[:content][/vid=([-\w]+)/, 1],
      hash2: og_video[:content][/embed_hash=([-\w]+)/, 1],
    } if og_image && og_video
  end
end
