require Rails.root.join('config/middleware/proxy_test')

class Proxies::Check
  method_object %i[proxy! ips is_caching]

  TEST_URL = "https://shikimori.one#{ProxyTest::TEST_PAGE_PATH}"
  IS_CACHING = false
  CACHE_VERSION = :v11

  def call
    (@is_caching.nil? || @is_caching) && IS_CACHING ?
      cached_check == 'true' :
      do_check
  end

private

  def ips
    @ips ||= Proxies::WhatIsMyIps.call
  end

  def cached_check
    Rails.cache.fetch([@proxy.to_s, CACHE_VERSION], expires_in: expires_in) do
      do_check.to_s
    end
  end

  def do_check
    content = Proxy.get(TEST_URL, timeout: 10, proxy: @proxy)
    !!(
      content&.include?(ProxyTest::SUCCESS_CONFIRMATION_MESSAGE) &&
        ips.none? { |ip| content.include? ip }
    )
  rescue *::Network::FaradayGet::NET_ERRORS
    false
  end

  def expires_in
    proxy.socks4? || proxy.socks5? ? 30.minutes : 2.hours
  end
end
