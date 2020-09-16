class Network::FinalUrl
  method_object :url

  def call
    NamedLogger.download_final_url.info "#{@url} start"
    result = faraday_get @url
    NamedLogger.download_final_url.info "#{@url} end"

    Url.new(result.env[:url].to_s).to_s if result
  end

private

  def faraday_get url
    Network::FaradayGet.call url
  end
end
