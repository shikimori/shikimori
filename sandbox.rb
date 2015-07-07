#!/usr/bin/env ruby
ENV['RAILS_ENV'] = ARGV.first || ENV['RAILS_ENV'] || 'development'
require File.expand_path(File.dirname(__FILE__) + "/config/environment")

require 'zlib'

class Faraday::Gzip < Faraday::Response::Middleware
  def call env
    @app.call(env).on_complete do |res|
      encoding = env[:response_headers]['content-encoding'].to_s.downcase
      case encoding
      when 'gzip'
        env[:body] = Zlib::GzipReader.new(StringIO.new(env[:body]), encoding: 'ASCII-8BIT').read
        env[:response_headers].delete('content-encoding')
      when 'deflate'
        env[:body] = Zlib::Inflate.inflate(env[:body])
        env[:response_headers].delete('content-encoding')
      end
    end
  end
end

class Faraday::PersistedCookies < Faraday::Middleware
  def initialize app, options={}
    super app
    @cookies = options[:cookies]# || HTTP::CookieJar.new
  end

  def call env
    env[:cookies] ||= @cookies
    cookies = @cookies.cookies env[:url]

    env[:request_headers]["Cookie"] = HTTP::Cookie.cookie_value(cookies) unless cookies.empty?

    @app.call(env).on_complete do |res|
      if res[:response_headers] && res[:response_headers]["Set-Cookie"]
        @cookies.parse res[:response_headers]["Set-Cookie"], env[:url]
      end
    end
  end
end

class Faraday::IncapsulaUnsuccessful < Faraday::Middleware
  def call env
    perform_with_iframe_check env
  end

  def perform_with_iframe_check env
    response = @app.call env

    response.on_complete do |res|
      if with_iframe?(res)
        binding.pry
        iframe_response = fetch_iframe iframe_url(env, res), env[:cookies]
        binding.pry

        #env[:original_url] = env[:url]
        #env[:url] += iframe_url(env, res)
        #@app.call(env)

        #ap '-----------'
        #ap env[:cookies]
        #ap env[:body]

        #env[:url] += env[:original_url]
        #response = @app.call env

        #ap '-----------'
        #ap env[:cookies]
        #ap env[:body]
      end
    end

    response
  end

  def with_iframe? res
    res[:body] =~ /Request unsuccessful. Incapsula incident ID/
  end

  def iframe_url env, res
    "http://#{env[:url].hostname}#{res[:body][/(?<= src=") .*? (?= ")/x]}"
  end

  def fetch_iframe url, cookies
    conn = Faraday.new do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.response :gzip
      faraday.adapter Faraday.default_adapter

      faraday.use :persisted_cookies, cookies: cookies
    end

    conn.headers['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
    conn.headers['Accept-Encoding'] = 'gzip,deflate,sdch'
    conn.headers['Accept-Language'] = 'en-US,en;q=0.8'
    conn.headers['Connection'] = 'keep-alive'
    conn.headers['DNT'] = '1'
    conn.headers['User-Agent'] = 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'

    conn.get url
  end
end

Faraday.register_middleware persisted_cookies: lambda { Faraday::PersistedCookies }
Faraday.register_middleware incapsula_unsuccessful: lambda { Faraday::IncapsulaUnsuccessful }
Faraday::Response.register_middleware gzip: lambda { Faraday::Gzip }


class Far
  def do
    conn = Faraday.new do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.response :gzip
      faraday.adapter Faraday.default_adapter

      faraday.use :incapsula_unsuccessful
      faraday.use :persisted_cookies, cookies: HTTP::CookieJar.new
    end

    conn.headers['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
    conn.headers['Accept-Encoding'] = 'gzip,deflate,sdch'
    conn.headers['Accept-Language'] = 'en-US,en;q=0.8'
    conn.headers['Connection'] = 'keep-alive'
    conn.headers['DNT'] = '1'
    conn.headers['User-Agent'] = 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'

    response = conn.get 'http://myanimelist.net/'
  end
end

#class Faraday::PersistedCookies < Faraday::Middleware
  #def initialize app
    #super
    #@cookies = HTTP::CookieJar.new
  #end

  #def call env
    #cookies = @cookies.cookies env[:url]

    #env[:request_headers]["Cookie"] = HTTP::Cookie.cookie_value(cookies) unless cookies.empty?

    #@app.call(env).on_complete do |res|
      #if res[:response_headers] && res[:response_headers]["Set-Cookie"]
        #@cookies.parse res[:response_headers]["Set-Cookie"], env[:url]
      #end
    #end
  #end
#end

#class Faraday::IncapsulaUnsuccessful do
  ##Request unsuccessful. Incapsula incident ID

  #def call env
    #response = @app.call(env)

    #binding.pry
    #response.on_complete do |res|
    #end
  #end
#end

#Faraday.register_middleware persisted_cookies: lambda { Faraday::PersistedCookies }
#Faraday.register_middleware incapsula_unsuccessful: lambda { Faraday::IncapsulaUnsuccessful }


#conn = Faraday.new do |faraday|
  #faraday.request  :url_encoded
  #faraday.response :logger
  #faraday.adapter Faraday.default_adapter
  ##faraday.use Faraday::PersistedCookies
  #faraday.use :persisted_cookies
  #faraday.use :incapsula_unsuccessful
#end;

#conn.headers['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8';
#conn.headers['Accept-Encoding'] = 'gzip,deflate,sdch';
#conn.headers['Accept-Language'] = 'en-US,en;q=0.8';
#conn.headers['Connection'] = 'keep-alive';
#conn.headers['DNT'] = '1';
##conn.headers['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.101 Safari/537.36';
#conn.headers['User-Agent'] = 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)';

#response = conn.get 'http://myanimelist.net/'
#response.body

#Nokogiri::HTML(response.body).css('script').text.strip

#cxt = V8::Context.new
#cxt.eval('7 * 6')


exit
Review.where(user_id: 2357).update_all state: :accepted, approver_id: 1
exit
Message.wo_antispam do
  User.where(id: UserToken.where(provider: ['google_apps', 'yandex']).map(&:user_id)).each do |user|
    message = Message.create(
      from_id: 1,
      to_id: user.id,
      kind: MessageType::Private,
      body: "Привет!
Где-то во второй половине Июля на сайте произойдёт обновление, которое навсегда поломает авторизацию через Google и Yandex. Авторизация через эти сервисы будет отключена ([spoiler=возможно]позже может быть вернётся назад немного в другом виде, но войти в прежние аккаунты через неё не выйдет[/spoiler]).
Немного уточню, речь идёт не о регистрации на почту гугла или яндекса, а о регистрация через одну из этих двух кнопочек 
[url=http://img855.imageshack.us/img855/4896/88820130613005456.png][img]http://img855.imageshack.us/img855/4896/88820130613005456.th.png[/img][/url]

Пишу вам это сообщение, т.к. вы зарегистрированы на сайте как раз через Google(Yandex).
Пожалуйста, убедитесь, что сможете в дальнейшем залогиниться на сайт без этого способа.
Для этого в настройках профиля должен быть задан емайл и пароль, либо же подключён к аккаунту ещё один способ авторизации через вконтакт или фейсбук.
[url=http://img43.imageshack.us/img43/9965/88820130613005332.png][img]http://img43.imageshack.us/img43/9965/88820130613005332.th.png[/img][/url]

Прошу прощения за доставленные неудобства :bow:"
    )
    ShikiMailer.delay.private_message_email(message)
  end
end
