class VideoExtractor::VkExtractor < VideoExtractor::BaseExtractor
  URL_REGEX = %r{
    https?://vk.com/video-?(\d+)_(\d+)
  }xi

  def image_url
    parsed_data['jpg']
  end

  def player_url
    "https://vk.com/video_ext.php?oid=#{parsed_data['oid']}&id=#{parsed_data['vid']}&hash=#{parsed_data['hash2']}&hd=1"
  end

  def parse_data html
    data = html.match(/vars = ({.*?});\\nvar/) || raise(EmptyContent, @url)
    JSON.parse data[1].gsub(/\\/, '')
  end
end
