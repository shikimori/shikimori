class NoProxies < Exception
  def initialize(url)
    super "no proxies to perform request: #{url}"
  end
end
