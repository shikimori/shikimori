class VideoExtractor::VkExtractor < VideoExtractor::BaseExtractor
  URL_REGEX = %r{https?://vk.com/video-?(\d+)_(\d+)}

  def image_url
    parsed_data['jpg']
  end

  def player_url
    "https://vk.com/video_ext.php?oid=#{parsed_data['oid']}&id=#{parsed_data['vid']}&hash=#{parsed_data['hash2']}&hd=1"
  end

  def parsed_data
    @parsed_data ||= Rails.cache.fetch @url, expires_in: 2.weeks do
      data = fetch_page.match(/vars = ({.*?});\\nvar/) || raise(EmptyContent, @url)
      JSON.parse data[1].gsub(/\\/, '')
    end
  end

  def fetch_page
    @fetched_page ||= open(@url).read
  end
end
