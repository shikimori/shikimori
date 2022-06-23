require Rails.root.join('config/middleware/proxy_test')

class Proxies::Check
  method_object %i[proxy! ips]

  TEST_URL = "https://shikimori.org#{ProxyTest::TEST_PAGE_PATH}"
  IS_CACHING = true
  CACHE_VERSION = :v10

  def call
    if IS_CACHING
      cached_check == 'true'
    else
      do_check
    end
  end

private

  def ips
    @ips ||= Proxies::WhatIsMyIps.call
  end

  def cached_check
    Rails.cache.fetch([@proxy.to_s, CACHE_VERSION], expires_in: expires_in) do
      (!!do_check).to_s
    end
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
