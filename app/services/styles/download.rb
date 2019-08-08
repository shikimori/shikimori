class Styles::Download
  method_object :url

  CACHE_KEY = 'style_%<url>s'
  EXPIRES_IN = 8.hours

  def call
    "/* #{@url} */\n" + sanitize(cached_download)
  end

private

  def sanitize css
    Misc::SanitizeEvilCss.call css
  end

  def cached_download
    Rails.cache.fetch format(CACHE_KEY, url: @url), expires_in: EXPIRES_IN do
      download
    end
  end

  def download
    content = Network::FaradayGet.call(@url)&.body&.force_encoding('utf-8') || ''
    content.valid_encoding? ? content : ''
  end
end
