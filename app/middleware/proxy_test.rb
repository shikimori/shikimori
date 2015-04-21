class ProxyTest
  SUCCESS_CONFIRMATION_MESSAGE = "test_passed"

  TEST_PAGE_PATH = "/proxy_test"
  WHAT_IS_MY_IP_PATH = "/what_is_my_ip"

  def initialize app
    @app = app
  end

  def call env
    if env['PATH_INFO'] == TEST_PAGE_PATH # тест прокси
      data = env.select {|k,v| k =~ /^[A-Z_]+$/ && k != 'SERVER_ADDR' && k != 'HTTP_COOKIE' }.map {|k,v| v }.join " | "
      [200, {'Content-Type' => 'text/plain'}, [
        "#{data} #{SUCCESS_CONFIRMATION_MESSAGE}"
      ]]
    elsif env['PATH_INFO'] == WHAT_IS_MY_IP_PATH # выдача ip
      [200,
        {'Content-Type' => 'text/plain'},
        [
          env['HTTP_X_FORWARDED_FOR'] || env['HTTP_X_REAL_IP'] || env['REMOTE_ADDR']
        ]
      ]
    else
      @app.call(env)
    end
  end
end
