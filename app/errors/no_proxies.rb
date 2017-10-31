class NoProxies < StandardError
  def initialize url
    super "no proxies to perform request: #{url}"
  end
end
