class VideoExtractor::BaseExtractor
  vattr_initialize :url
  attr_implement :parse_data

  ALLOWED_EXCEPTIONS = Network::FaradayGet::NET_ERRORS
  PARAMS = /(?:(?:\?|\#|&amp;|&)[\w=+%-]+)*/.source

  USER_AGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 ' \
    '(KHTML, like Gecko) Chrome/39.0.2171.71 Safari/537.36'

  OPEN_URI_OPTIONS = {
    'User-Agent' => USER_AGENT,
    ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE,
    allow_redirections: :all,
    read_timeout: 7
  }

  def url
    @parsed_url ||= @url if URI.parse @url
  rescue StandardError
    @parsed_url ||= URI.encode(@url)
  end

  def video_data_url
    url
  end

  def fetch
    Retryable.retryable tries: 2, on: ALLOWED_EXCEPTIONS, sleep: 1 do
      return unless valid_url?

      entry = PgCache.fetch url, expires_in: 2.years do
        fetch_and_build_entry
      end

      entry if entry&.image_url && entry&.player_url
    end
  rescue *(ALLOWED_EXCEPTIONS + [EmptyContentError])
    nil
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

  def fetch_and_build_entry
    NamedLogger.download_video.info "#{url} start"

    entry =
      if parsed_data.present?
        Videos::ExtractedEntry.new(hosting, image_url, player_url)
      end

    NamedLogger.download_video.info "#{url} end"
    entry
  end

  def parsed_data
    @parsed_data ||= {}
    @parsed_data[url] ||= parse_data(fetch_page)
  end

  def fetch_page
    OpenURI.open_uri(video_data_url, self.class::OPEN_URI_OPTIONS).read
  end
end
