MalParser.configuration.http_get = lambda do |url|
  Rails.cache.fetch(url, expires_in: 1.day) do
    begin
      open(url).read
    rescue OpenURI::HTTPError => e
      raise unless e.message =~ /404 Not Found/
    end
  end
end
