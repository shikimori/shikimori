class MalParsers::Authorization
  include Singleton

  CACHE_KEY = 'mal_authorization_cookie'
  COOKIES = %w[MALSESSIONID is_logged_in=1]

  LOGIN_PATH = '/login.php?from=%2F'

  HEADERS = {
    'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) '\
      'AppleWebKit/537.36 (KHTML, like Gecko) '\
      'Chrome/55.0.2883.95 Safari/537.36',
    'Accept' => 'text/html,application/xhtml+xml,application/xml;'\
      'q=0.9,image/webp,*/*;q=0.8',
    'Accept-Encoding' => 'identity',
    'Accept-Language' => 'en-US,en;q=0.8,ru;q=0.6',
    'Origin' => 'https://myanimelist.net',
    'Referer' => 'https://myanimelist.net/login.php?from=%2F'
  }
  LOGIN = 'shiki1'
  PASSWORD = 'PUcnnh0hM4MK'

  MALSESSIONID = '5icqpq8e0gdke4rtrut2f5o3f5'
  # MALSESSIONID = 'ja5legpvs3ri2iuqn39uh8nvp4'

  def cookie
    %W[
      MALSESSIONID=#{MALSESSIONID};
      is_logged_in=1;
    ]
    # RedisMutex.with_lock(self.class.name, block: 0) do
    #   Rails.cache.fetch(CACHE_KEY) { authorize }
    # end
  end

  def refresh
    raise 'have to refresh MAL cookie!'
    # Rails.cache.delete CACHE_KEY
    # cookie
  end

private

  def authorize
    connection = Faraday.new('https://myanimelist.net', connection_options) do |builder|
      builder.use :cookie_jar
      builder.adapter Faraday.default_adapter
    end
    csrf_token = csrf_token connection

    response = connection.post LOGIN_PATH, login_params(csrf_token), HEADERS
    cookies = parse_cookies response.headers['set-cookie']

    raise 'mal unauthorized' unless valid? cookies

    cookies
  end

  def parse_cookies cookie_header
    cookie_header
      .split(',')
      .select { |v| v =~ /=/ && COOKIES.any? { |cookie| v.include? cookie } }
      .map { |v| v.gsub(/;.*/, ';').strip }
  end

  def csrf_token connection
    response = connection.get LOGIN_PATH, HEADERS
    Nokogiri::HTML(response.body).at_css('meta[name=csrf_token]').attr(:content)
  end

  def login_params csrf_token
    %W[
      user_name=#{LOGIN}
      password=#{PASSWORD}
      sublogin=Login
      submit=1
      csrf_token=#{csrf_token}
    ].join('&')
  end

  def valid? cookies
    cookies.size == 2
  end

  # https://proxy6.net/user/proxy
  def connection_options
    if Rails.application.secrets.proxy[:url]
      {
        proxy: {
          uri: Rails.application.secrets.proxy[:url],
          user: Rails.application.secrets.proxy[:login],
          password: Rails.application.secrets.proxy[:password]
        }
      }
    else
      {}
    end
  end
end
