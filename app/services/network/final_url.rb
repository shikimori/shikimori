class Network::FinalUrl
  method_object :url

  def call
    result = faraday_get url
    Url.new(result.env[:url].to_s).to_s if result
  end

private

  def faraday_get url
    response = Network::FaradayGet.call url
    return false unless response&.status == 200
    response
  end
end
