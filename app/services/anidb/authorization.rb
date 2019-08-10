# frozen_string_literal: true

class Anidb::Authorization
  include Singleton

  CACHE_KEY = 'anidb_authorization_cookie'
  COOKIES = %w[
    adbsess
    adbss
    adbsessuser
    anidbsettings
    adbautouser
    adbautopass
  ]

  LOGIN_PATH = '/perl-bin/animedb.pl?show=login'
  LOGIN = 'naruto1451'
  PASSWORD = 'Wy6F27yNuDFB'

  HEADERS = {
    'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) '\
      'AppleWebKit/537.36 (KHTML, like Gecko) '\
      'Chrome/55.0.2883.95 Safari/537.36',
    'Accept' => 'text/html,application/xhtml+xml,application/xml;'\
      'q=0.9,image/webp,*/*;q=0.8',
    'Accept-Encoding' => 'gzip, deflate',
    'Accept-Language' => 'en-US,en;q=0.8,ru;q=0.6,ja;q=0.4',
    'Origin' => 'http://anidb.net',
    'Referer' => 'http://anidb.net/perl-bin/animedb.pl?show=login'
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
    connection = Faraday.new('http://anidb.net') do |faraday|
      faraday.use :cookie_jar
      faraday.adapter Faraday.default_adapter
    end

    response = connection.post LOGIN_PATH, login_params, HEADERS
    cookies = parse_cookies response.headers['set-cookie']

    raise 'anidb unauthorized' unless valid?(cookies)

    cookies
  end

  def parse_cookies cookie_header
    cookie_header
      .split(',')
      .select { |v| v =~ /=/ && COOKIES.any? { |cookie| v.include? cookie } }
      .map { |v| v.gsub(/;.*/, ';').strip }
  end

  def login_params
    %W[
      show=main
      xuser=#{LOGIN}
      xpass=#{PASSWORD}
      xdoautologin=on
      xkeepoldcookie=on
      do.auth.x=Login
    ].join('&')
  end

  def valid? cookies
    cookies.size == COOKIES.size
  end
end
