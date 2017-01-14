REQUIRED_TEXT = [
  'MyAnimeList.net</title>',
  '</html>'
]
BAD_ID_ERRORS = [
  'Invalid ID provided',
  'No manga found, check the manga id and try again',
  'No series found, check the series id and try again'
]

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
    content = Proxy.get(
      url,
      timeout: 30,
      required_text: REQUIRED_TEXT,
      no_proxy: Rails.env.test?,
      log: !Rails.env.test?
    )

    raise EmptyContentError, url unless content
    raise InvalidIdError, url if BAD_ID_ERRORS.any? { |v| content.include? v }

    content

    # begin
      # open(url, headers).read
    # rescue OpenURI::HTTPError => e
      # raise unless e.message =~ /404 Not Found/
    # end
  end
end
