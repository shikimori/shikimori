class Network::FinalUrl < ServiceObjectBase
  method_object :url

  GENERIC_ANDROID_URL = 'https://play.google.com/store/apps/details?id=%s&hl=ru'
  MOBILE_ANDROID_URL = %r{
    market://details\?id=
      (?<id>
       .*? (?= &|$ )
      )
  }mix

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
