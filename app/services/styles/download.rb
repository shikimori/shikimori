class Styles::Download
  method_object :url

  EXPIRES_IN = 8.hours

  CACHE_VERSION = :v1
  CACHE_KEY = "style_%<url>s_#{CACHE_VERSION}"

  ALLOWED_EXCEPTIONS = Network::FaradayGet::NET_ERRORS

  def call
    Rails.cache.fetch format(CACHE_KEY, url: @url), url: @url, expires_in: EXPIRES_IN do
      Retryable.retryable tries: 2, on: ALLOWED_EXCEPTIONS, sleep: 1 do
        download
      end
    end
  rescue StandardError
    ''
  end

private

  def download
    NamedLogger.download_style.info "#{@url} start"
    content = Network::FaradayGet.call(@url)&.body&.force_encoding('utf-8') || ''
    NamedLogger.download_style.info "#{@url} end"
    content.valid_encoding? ? content : ''
  end
end
