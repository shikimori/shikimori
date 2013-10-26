class Redirecter
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    if request.host != 'dev.shikimori.de' && request.host != 'dev.shikimori.org' && request.host != 'shikimori.dev' && request.host != 'shikimori.org' && request.host != 'shikimori.de'
      [301, {"Location" => request.url.sub(request.host, 'shikimori.org')}, []]

    elsif request.host.starts_with?("www.")
      [301, {"Location" => request.url.sub("//www.", "//")}, self]

    elsif request.url.end_with?('/') && request.path != '/'
      [301, {"Location" => request.url.sub(/\/$/, '')}, []]

    elsif request.url.include?('?') && !request.url.include?('reset_password') && !request.url.include?('/users/auth/') && !request.url.include?('/api/') && request.path !~ /\.(css|js)\Z/
      [301, {"Location" => request.url.sub(/\?.*/, '')}, []]

    else
      @app.call(env)
    end
  end
end
