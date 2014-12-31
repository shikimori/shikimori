class VideoExtractor::BaseExtractor
  attr_reader :url

  def initialize url
    @url = url if URI.parse url
  rescue
    @url = URI.encode url
  end

  def fetch
    VideoData.new hosting, image_url, player_url if valid_url? && opengraph_page?

  rescue OpenURI::HTTPError => e
  rescue EmptyContent => e
  rescue URI::InvalidURIError => e
  end

  def hosting
    self
      .class
      .name
      .to_underscore
      .sub(/.*::_?/, '')
      .sub(/_extractor/, '')
      .to_sym
  end

  def valid_url?
    self.class.valid_url? url
  end

  def opengraph_page?
    parsed_data.present?
  end

  def self.valid_url? url
    url =~ self::URL_REGEX
  end

  def parsed_data
    @parsed_data ||= Rails.cache.fetch @url, expires_in: 2.weeks do
      parse_data fetch_page
    end
  end

  def fetch_page
    @fetched_page ||= open(@url).read
  end
end
