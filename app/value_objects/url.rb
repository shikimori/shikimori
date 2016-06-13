class Url
  REGEXP = %r{
    \A
    (?<protocol>https?://)
    (?:
      (?<domain>[^/:]+)
      (?<port>:\d+)
      |
      (?<domain>[^/]+)
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

  def with_http
    chain @url.sub(%r{\A(?!https?://)}, 'http://')
  end

  def without_http
    chain @url.sub(%r{\A(?:https?:)?//}, '')
  end

  def protocolless
    chain '//' + without_http.to_s
  end

  def domain
    chain without_http.to_s.gsub(%r{/.*|\?.*}, '')
  end

  def cut_www
    chain @url.sub(%r{\A(https?://)?www\.}, '\1')
  end

private

  def protocol? string
    string.starts_with?('https://') || string.starts_with?('http://')
  end

  def chain string
    Url.new string
  end
end
