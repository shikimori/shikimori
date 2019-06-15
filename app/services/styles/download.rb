class Styles::Download
  method_object :url

  CACHE_KEY = 'style_%<url>s'
  EXPIRES_IN = 8.hours

  def call
    Rails.cache.fetch format(CACHE_KEY, url: @url), expires_in: EXPIRES_IN do
      "// #{@url}\n" + sanitize(download)
    end
  end

private

  def sanitize css
    Misc::SanitizeEvilCss.call css
  end

  def download
    Network::FaradayGet.call(@url)&.body || ''
  end
end
