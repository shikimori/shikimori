# frozen_string_literal: true

class Anidb::Authorization
  include Singleton

  CACHE_KEY = 'anidb_authorization_cookie'
  COOKIES = %w[
    adbuin
    adbsess
    adbsessuser
    adbss
    anidbsettings
  ]

  ROOT_PATH = '/'
  LOGIN_PATH = '/perl-bin/animedb.pl'
  LOGIN = Rails.env.test? ? 'naruto1452' : 'naruto1455'
  PASSWORD = 'Wy6F27yNuDFB'

  HEADERS = {
    'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) '\
      'AppleWebKit/537.36 (KHTML, like Gecko) '\
      'Chrome/55.0.2883.95 Safari/537.36',
    'Accept' => 'text/html,application/xhtml+xml,application/xml;'\
      'q=0.9,image/webp,*/*;q=0.8',
    'Accept-Encoding' => 'gzip, deflate',
    'Accept-Language' => 'en-US,en;q=0.8,ru;q=0.6,ja;q=0.4',
    'Origin' => 'http://anidb.net'
  }

  # NOTE: space between cookies is important for anidb
  def cookie_string
    cookie.join(' ')
  end

  def cookie
    RedisMutex.with_lock(self.class.name, block: 0) do
      Rails.cache.fetch(CACHE_KEY) { authorize }
    end
  end

  def refresh
    Rails.cache.delete CACHE_KEY
    cookie
  end

private

  def authorize
    connection = Faraday.new('https://anidb.net') do |faraday|
      faraday.use :cookie_jar
      faraday.adapter Faraday.default_adapter
    end

    response1 = connection.get ROOT_PATH, HEADERS
    cookies1 = parse_cookies response1.headers['set-cookie']

    response2 = connection.post LOGIN_PATH, login_params, HEADERS.merge(
      'Referer' => 'https://anidb.net/'
    )
    cookies2 = parse_cookies response2.headers['set-cookie']

    cookies = cookies1 + cookies2

    raise 'anidb unauthorized' unless valid? cookies

    cookies
  end

  def parse_cookies cookie_header
    cookie_header
      .split(',')
      .select do |v|
        v.include?('=') && COOKIES.any? { |cookie| v.include? cookie }
      end
      .map { |v| v.gsub(/;.*/, ';').strip }
  end

  def login_params
    %W[
      show=main
      xuser=#{LOGIN}
      xpass=#{PASSWORD}
      xdoautologin=on
      do.auth=Login
    ].join('&')
  end

  def valid? cookies
    cookies.size == COOKIES.size
  end
end
