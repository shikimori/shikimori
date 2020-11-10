class Redirecter
  VALID_HOSTS = ShikimoriDomain::HOSTS

  def initialize app
    @app = app
  end

  def call env
    request = Rack::Request.new env

    return @app.call(env) unless request.get?

    if !VALID_HOSTS.include? request.host
      [301, { 'Location' => fixed_url(request).sub(request.host, Shikimori::DOMAIN) }, []]

    elsif request.host.starts_with? 'www.'
      [301, { 'Location' => fixed_url(request).sub('//www.', '//') }, self]

    elsif request.url.end_with?('/') && request.path != '/'
      [301, { 'Location' => fixed_url(request).sub(%r{/$}, '') }, []]

    elsif request.url.end_with?('&') && request.path != '/'
      [301, { 'Location' => fixed_url(request).sub(/&$/, '') }, []]

    elsif request.url.end_with?('.html')
      [301, { 'Location' => fixed_url(request).sub(/.html$/, '') }, []]

    elsif request.path.match?(%r{//+})
      [301, { 'Location' => request.path.sub(%r{//+}, '/') }, []]

    else
      @app.call(env)
    end
  end

  def fixed_url request
    # need to strip port because for some reason requests proxied to shiki_db have port in request.url
    request.url.sub(%r{:80(?=/|$)}, '\1')
  end
end
