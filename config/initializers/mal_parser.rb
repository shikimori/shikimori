MalParser.configuration.http_get = lambda do |url|
  cookie = %w(
    MALHLOGSESSID=978fea4e54380b5c421580ee33e7b521;
    MALSESSIONID=7s6s7botsaklcg3dhrp8i36in4;
    is_logged_in=1;
  ).join
  headers = {
    'Cookie' => cookie
  }

  Rails.cache.fetch(url, expires_in: 1.day) do
    begin
      open(url, headers).read
    rescue OpenURI::HTTPError => e
      raise unless e.message =~ /404 Not Found/
    end
  end
end
