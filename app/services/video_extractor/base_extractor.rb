class VideoExtractor::BaseExtractor
  include Singleton

  attr_implement :parse_data, :extract_image_url, :extract_player_url

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

  def fetch url
    fixed_url = normalize_url url
    return unless valid_url? fixed_url

    if remote_request_required?
      fetch_remote fixed_url
    else
      fetch_local fixed_url
    end
  end

  def fetch_remote url
    Retryable.retryable tries: 2, on: ALLOWED_EXCEPTIONS, sleep: 1 do
      PgCache.fetch url, expires_in: 2.years do
        fetch_and_build_entry url
      end
    end
  rescue *(ALLOWED_EXCEPTIONS + [EmptyContentError])
    nil
  end

  def fetch_local url
    match = url.match self.class::URL_REGEX

    Videos::ExtractedEntry.new(
      extract_hosting(url),
      extract_image_url(match),
      extract_player_url(match)
    )
  end

  def valid_url? url
    url.match? self.class::URL_REGEX
  end

  def normalize_url url
    fixed_url = begin
      url if URI.parse url
    rescue StandardError
      Addressable::URI.encode(url).gsub('%20', ' ')
    end

    fixed_url.gsub('http://', 'https://')
  end

private

  def remote_request_required?
    true
  end

  def fetch_and_build_entry url
    NamedLogger.download_video.info "#{url} start"

    content = fetch_page url
    data = parse_data content, url if content.present?
    entry = nil

    if data.present?
      entry = Videos::ExtractedEntry.new(
        extract_hosting(url),
        extract_image_url(data),
        extract_player_url(data)
      )
    end

    NamedLogger.download_video.info "#{url} end"

    entry if entry && entry.image_url.present? && entry.player_url.present?
  end

  def video_api_url url
    url
  end

  def extract_hosting _url
    self
      .class
      .name
      .to_underscore
      .sub(/.*::_?/, '')
      .sub(/_extractor/, '')
      .to_sym
  end

  def fetch_page url
    OpenURI.open_uri(video_api_url(url), open_uri_options).read
  end

  def open_uri_options
    self.class::OPEN_URI_OPTIONS
  end
end
