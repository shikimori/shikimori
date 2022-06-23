require Rails.root.join('config/middleware/proxy_test')

class Proxies::Check
  method_object %i[proxy! ips]

  TEST_URL = "https://shikimori.org#{ProxyTest::TEST_PAGE_PATH}"

  def call
    content = Proxy.get(TEST_URL, timeout: 10, proxy: @proxy)
    binding.pry
    content&.include?(ProxyTest::SUCCESS_CONFIRMATION_MESSAGE) &&
      ips.none? { |ip| content.include? ip }
  rescue *::Network::FaradayGet::NET_ERRORS
    false
  end

private

  def ips
    @ips || Proxies::WhatIsMyIps.call
  end
end
