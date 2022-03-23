require Rails.root.join('config/middleware/proxy_test')

class Proxies::WhatIsMyIps
  method_object

  WHAT_IS_MY_IP_URL = "https://#{Shikimori::DOMAINS[:production]}#{ProxyTest::WHAT_IS_MY_IP_PATH}"

  def call
    @@ips ||= begin # rubocop:disable ClassVars MissingCop
      log 'getting own ip... '
      ips = OpenURI.open_uri(WHAT_IS_MY_IP_URL).read.strip.split(',').map(&:strip)
      log "#{ips.join(',')}\n"
      ips
    end
  end

private

  def log text
    print text unless Rails.env.test? # rubocop:disable Rails/Output
  end
end
