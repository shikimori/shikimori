class VideoExtractor::BaseExtractor
  vattr_initialize :url
  attr_implement :parse_data

  ALLOWED_EXCEPTIONS = [Errno::ECONNRESET, Net::ReadTimeout]

  def url
    @parsed_url ||= @url if URI.parse @url
  rescue
    @parsed_url ||= URI.encode @url
  end

  def fetch_url
    url
  end

  def fetch
    Retryable.retryable tries: 2, on: ALLOWED_EXCEPTIONS, sleep: 1 do
      if valid_url? && opengraph_page?
        VideoData.new hosting, image_url, player_url
      end
    end

  rescue OpenURI::HTTPError, EmptyContentError, URI::InvalidURIError,
      SocketError, TypeError, Net::OpenTimeout => e
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
    url.match? self::URL_REGEX
  end

  def parsed_data
    @parsed_data ||= Rails.cache.fetch url, expires_in: 2.weeks do
      parse_data fetch_page
    end
  end

  def fetch_page
    @fetched_page ||= open(fetch_url,
      'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.71 Safari/537.36',
      ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE,
      allow_redirections: :all,
      proxy_http_basic_authentication: Rails.env.production? ? nil : [
        URI.parse('http://178.79.156.106:3128'),
        'uptimus',
        'holy_grail'
      ]
    ).read
  end
end
