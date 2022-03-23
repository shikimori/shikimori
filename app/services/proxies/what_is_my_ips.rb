class Proxies::WhatIsMyIps
  method_object

  WHAT_IS_MY_IP_PATH = '/what_is_my_ip'
  WHAT_IS_MY_IP_URL = "https://#{Shikimori::DOMAINS[:production]}#{WHAT_IS_MY_IP_PATH}"

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
    print text # rubocop:disable Rails/Output
  end
end
