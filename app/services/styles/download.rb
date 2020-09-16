class Styles::Download
  method_object :url

  CACHE_KEY = 'style_%<url>s'
  EXPIRES_IN = 8.hours

  ALLOWED_EXCEPTIONS = Network::FaradayGet::NET_ERRORS

  def call
    "/* #{@url} */\n" + sanitize(cached_download)
  end

private

  def sanitize css
    Misc::SanitizeEvilCss.call css
  end

  def cached_download
    Rails.cache.fetch format(CACHE_KEY, url: @url), expires_in: EXPIRES_IN do
      Retryable.retryable tries: 2, on: ALLOWED_EXCEPTIONS, sleep: 1 do
        download
      end
    end
  end

  def download
    NamedLogger.download_style.info "#{@url} start"
    content = Network::FaradayGet.call(@url)&.body&.force_encoding('utf-8') || ''
    NamedLogger.download_style.info "#{@url} end"
    content.valid_encoding? ? content : ''
  end
end
