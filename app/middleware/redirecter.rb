class Redirecter
  VALID_HOSTS = ShikimoriDomain::HOSTS + AnimeOnlineDomain::HOSTS

  def initialize app
    @app = app
  end

  def call env
    request = Rack::Request.new env

    if !VALID_HOSTS.include? request.host
      [301, {"Location" => request.url.sub(request.host, Site::DOMAIN)}, []]

    elsif request.host.starts_with? 'www.'
      [301, {"Location" => request.url.sub('//www.', '//')}, self]

    elsif request.url.end_with?('/') && request.path != '/'
      [301, {"Location" => request.url.sub(/\/$/, '')}, []]

    elsif request.url.end_with?('&') && request.path != '/'
      [301, {"Location" => request.url.sub(/&$/, '')}, []]

    elsif request.get? && request.url.include?('?') &&
      !(request.url.include?('reset_password') || request.url.include?('/users/auth/') ||
        request.url.include?('/api/') || request.url.include?('/new?') || request.path =~ /\.(css|js)\Z/)
      [301, {"Location" => request.url.sub(/\?.*/, '')}, []]

    elsif request.url.end_with?('.html')
      [301, {"Location" => request.url.sub(/.html$/, '')}, []]

    else
      @app.call(env)
    end
  end
end
