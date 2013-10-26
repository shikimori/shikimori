Apipie.configure do |config|
  config.app_name                = "shikimori"
  config.api_base_url            = "/api"
  config.doc_base_url            = "/api/doc"
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/**/*.rb"
  config.default_version = "1"
end
