REQUIRED_TEXT = [
  'MyAnimeList.net</title>',
  '</html>'
]
BAD_ID_ERRORS = [
  'Invalid ID provided',
  'No manga found, check the manga id and try again',
  'No series found, check the series id and try again'
]
BAN_TEXTS = [
  'Access has been restricted for this account',
  'your IP has been banned from our website'
]

MalParser.configuration.http_get = lambda do |url|
  expires_in = url =~ /(?:anime|manga)\.php\?/ ? 1.hour : 8.hours
  html = Rails.cache.fetch([url, :v4], expires_in: expires_in) do
    content =
      begin
        Proxy.get(
          url,
          timeout: 30,
          required_text: REQUIRED_TEXT,
          ban_texts: BAN_TEXTS,
          no_proxy: Rails.env.test?,
          log: !Rails.env.test?
        )
      rescue OpenURI::HTTPError => e
        if e.message =~ /404 Not Found/
          BAD_ID_ERRORS.first
        else
          raise
        end
      end

    content || raise(EmptyContentError, url)
  end

  raise InvalidIdError, url if BAD_ID_ERRORS.any? { |v| html.include? v }
  html
end
