module CaptchaConcern
  extend ActiveSupport::Concern

  def valid_captcha? action
    return true if Rails.env.test?

    is_success = Shikimori::IS_TURNSTILE ?
      verify_turnstile :
      verify_google_captcha(action)

    @is_captcha_error = !is_success
    is_success
  end

private

  def verify_google_captcha action
    if Shikimori::IS_RECAPTCHA_V3
      auto_success = verify_recaptcha action: action,
        minimum_score: 0.4,
        secret_key: Rails.application.secrets.recaptcha[:v3][:secret_key]
    end
    checkbox_success = verify_recaptcha unless auto_success

    if auto_success || checkbox_success
      true
    else
      @is_captcha_error = true
      false
    end
  end

  def verify_turnstile # rubocop:disable Metrics/AbcSize
    return false if params[:'cf-turnstile-response'].blank?

    cf_response = Faraday.post do |req|
      req.url 'https://challenges.cloudflare.com/turnstile/v0/siteverify'
      req.headers['Authorization'] = 'foo'
      req.headers['Content-Type'] = 'application/json'
      req.options.timeout = 15
      req.options.open_timeout = 15
      req.body = {
        secret: Rails.application.secrets.turnstile[:secret_key],
        response: params[:'cf-turnstile-response']
      }.to_json
    end

    JSON.parse(cf_response.body, symbolize_names: true)[:success]
  end
end
