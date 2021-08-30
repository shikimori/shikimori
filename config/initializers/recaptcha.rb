Recaptcha.configure do |config|
  # weird bug: for some reason recaptcha is nil during deploy js:export task
  if Rails.application.secrets.recaptcha
    config.site_key = Rails.application.secrets.recaptcha[:v2][:site_key]
    config.secret_key = Rails.application.secrets.recaptcha[:v2][:secret_key]
  end
end
