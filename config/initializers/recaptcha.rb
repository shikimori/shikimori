puts Rails.application.secrets.to_json
puts Rails.application.secrets.recaptcha.to_json

Recaptcha.configure do |config|
  config.site_key = Rails.application.secrets.recaptcha[:site_key]
  config.secret_key = Rails.application.secrets.recaptcha[:secret_key]
end
