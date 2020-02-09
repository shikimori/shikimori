class Url
  REGEXP = %r{
    \A
    (?<protocol>https?://)
    (?:
      (?<domain>[^/:]+)
      (?<port>:\d+)
      |
      (?<domain>[^/?]+)
    )
    (?<path>.*)
    \Z
  }x

  pattr_initialize :url

  def to_s
    @url
  end

  def with_protocol
    if protocol? @url
      self
    else
      with_http
    end
  end

  def without_protocol
    chain '//' + without_http.to_s
  end

  def without_port
    chain @url.gsub %r{:\d+(?=/|\?|$)}, ''
  end

  def with_http
    chain @url.gsub(%r{\A// | \A(?!https?://)}mix, 'http://')
  end

  def without_http
    chain @url.sub(%r{\A(?:https?:)?//}, '')
  end

  def without_path
    chain @url.gsub(%r{(?<!/)/(?!/).*|\?.*}, '')
  end

  def domain
    chain without_http.without_port.to_s.gsub(%r{/.*|\?.*}, '')
  end

  def protocol
    chain @url.gsub(%r{\A(https?)://.* | \A .*}mix, '\1')
  end

  def add_www
    chain @url.sub(%r{\A(https?://)?(?:www\.)?}, '\1www.')
  end

  def cut_www
    chain @url.sub(%r{\A(https?://)?www\.}, '\1')
  end

  def cut_subdomain
    chain @url.sub(%r{\A(https?://)?[\w_-]+\.([\w_-]+\.[\w_-]+)}, '\1\2')
  end

  def cut_slash
    chain @url.sub(%r{/\Z}, '')
  end

  def params hash
    @url.split('?').first + '?' + query_string_updated(hash)
  end

  def param param_name
    current_query_string[param_name.to_s]
  end

private

  def query_string_updated new_params_hash
    query_string = current_query_string.reject do |param|
      new_params_hash[param.to_sym].present?
    end
    hash_to_query_string query_string.merge(new_params_hash)
  end

  def hash_to_query_string hash
    CGI.unescape(hash.to_query)
  end

  def current_query_string
    Rack::Utils.parse_query URI(@url).query
  end

  def protocol? string
    string.starts_with?('https://') || string.starts_with?('http://')
  end

  def chain string
    Url.new string
  end
end
