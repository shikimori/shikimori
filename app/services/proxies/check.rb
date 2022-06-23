require Rails.root.join('config/middleware/proxy_test')

class Proxies::Check
  method_object %i[proxy! ips]

  TEST_URL = "https://shikimori.org#{ProxyTest::TEST_PAGE_PATH}"
  SUCCESSFULL_RESULTS = ['true', true]

  def call
    Rails.cache
      .fetch(@proxy.to_s, expires_in: expires_in) { !!do_check.to_s }
      .in?(SUCCESSFULL_RESULTS)
  end

private

  def ips
    @ips ||= Proxies::WhatIsMyIps.call
  end

  def do_check
    content = Proxy.get(TEST_URL, timeout: 10, proxy: @proxy)
    content&.include?(ProxyTest::SUCCESS_CONFIRMATION_MESSAGE) &&
      ips.none? { |ip| content.include? ip }
  rescue *::Network::FaradayGet::NET_ERRORS
    false
  end

  def expires_in
    proxy.socks4? || proxy.socks5? ? 30.minutes : 2.hours
  end
end
