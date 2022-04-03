class Network::FaradayGet
  method_object :url

  TOO_LARGE_FOR_META_REDIRECT_SIZE = 10_000
  MAX_DEEP = 5

  NET_ERRORS = [
    Timeout::Error, Net::ReadTimeout, Net::OpenTimeout, Net::HTTPFatalError,
    OpenSSL::SSL::SSLError,
    URI::InvalidURIError, OpenURI::HTTPError,
    SocketError,
    Errno::ECONNRESET, Errno::ETIMEDOUT, Errno::EMFILE, Errno::EADDRNOTAVAIL, Errno::EINVAL,
    Faraday::ConnectionFailed, Faraday::TimeoutError, FaradayMiddleware::RedirectLimitReached,
    (Addressable::URI::InvalidURIError if defined? Addressable)
  ].compact

  def call
    process fixed_url(@url)
  rescue *NET_ERRORS
    nil
  rescue NoMethodError => error # thrown when @url == ''
    raise unless error.message == "undefined method `include?' for nil:NilClass"
  end

private

  def process url, deep = 0
    connection = Faraday.new(ssl: { verify: false }) do |builder|
      builder.use FaradayMiddleware::FollowRedirects, limit: 10
      builder.use :cookie_jar
      builder.adapter Faraday.default_adapter
    end

    response = connection.get(url) do |req|
      req.options.timeout = 5
      req.options.open_timeout = 2
    end

    check_meta_redirect response, deep
  end

  def fixed_url url
    Url.new(
      url.gsub('{', '%7B').gsub('}', '%7D').gsub('|', '%7C')
    ).with_protocol.to_s
  end

  def check_meta_redirect response, deep
    if deep < MAX_DEEP && response.body.size < TOO_LARGE_FOR_META_REDIRECT_SIZE
      redirect_url = ::Network::ExtractMetaRedirect.call(response.body)
      current_url = response.env.url.to_s

      redirect_url ?
        process(absolute_url(redirect_url, current_url), deep + 1) :
        response
    else
      response
    end
  end

  def absolute_url url, current_url
    case url
      when %r{^/(?!/)} then "#{Url.new(current_url).without_path}#{url}"
      when %r{^(?!http)(?!/)\w} then "#{current_url.gsub(%r{/[^/]*$}, '/')}#{url}"
      else url
    end
  end
end
