Apipie.configure do |config|
  config.app_name                = 'shikimori'
  config.api_base_url            = '/api'
  config.doc_base_url            = '/api/doc'
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/**/*.rb"
  config.default_version         = '1'
  config.app_info                = <<-DICK
Do not parse the main site. Use this api instead.

Do not mimic a browser. Put your application name or website url in User-Agent request header.

Do not make more than 3 requests per second by ip address for mobile applications.

Do not make more than 10 requests per second from your webserver.

Message me (http://shikimori.org/morr or takandar@gmail.com) if you have any questions or you need more data in api.
DICK
end
