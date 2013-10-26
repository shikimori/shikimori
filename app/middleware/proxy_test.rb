class ProxyTest
  SuccessConfirmationMessage = "test_passed"

  TestPage = "/proxy_test"
  WhatIsMyIpPage = "/what_is_my_ip"

  def initialize(app)
    @app = app
  end

  def call(env)
    if env['PATH_INFO'] == TestPage # тест прокси
      data = env.select {|k,v| k =~ /^[A-Z_]+$/ && k != 'SERVER_ADDR' && k != 'HTTP_COOKIE' }.map {|k,v| v }.join " | "
      [200, {'Content-Type' => 'text/plain'}, [
        "#{data} #{SuccessConfirmationMessage}"
      ]]
    elsif env['PATH_INFO'] == WhatIsMyIpPage # выдача ip
      [200,
        {'Content-Type' => 'text/plain'},
        [
          env['REMOTE_ADDR']
        ]
      ]
    else
      @app.call(env)
    end
  end
end
