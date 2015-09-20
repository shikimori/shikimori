Apipie.configure do |config|
  config.app_name                = 'shikimori'
  config.api_base_url            = '/api'
  config.doc_base_url            = '/api/doc'
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/**/*.rb"
  config.default_version         = '1'
  config.app_info                = <<-DICK
Do not parse the main site. Use this api instead.

Do not mimic a browser. Put your application name or website url in User-Agent request header.

API access limits: 5 requests per second, 90 requests per minute

Message me (http://shikimori.org/morr or takandar@gmail.com) if you have any questions or you need more data in api.


Authentication:
1. Retrieve an api access token from http://shikimori.org/api/doc/1/access_tokens/show.html
2. Add X-User-Nickname & X-User-Api-Access-Token request headers to each your api request

X-User-Nickname=user_nickname

X-User-Api-Access-Token=user_api_access_token
DICK
end
