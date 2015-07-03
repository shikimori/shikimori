class VideoExtractor::BaseExtractor
  attr_reader :url

  def initialize url
    @url = url if URI.parse url
  rescue
    @url = URI.encode url
  end

  def fetch
    VideoData.new hosting, image_url, player_url if valid_url? && opengraph_page?

  rescue OpenURI::HTTPError, EmptyContent, URI::InvalidURIError, SocketError, TypeError
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
    @fetched_page ||= open(@url,
      'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.71 Safari/537.36',
      ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE,
      allow_redirections: :all
    ).read
  end
end
