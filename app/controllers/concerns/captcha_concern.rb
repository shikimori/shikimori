module CaptchaConcern
  extend ActiveSupport::Concern

  ALLOWED_EXCEPTIONS = Network::FaradayGet::NET_ERRORS

  def valid_captcha? action
    return true if Rails.env.test?

    is_success = verify_turnstile || verify_google_captcha(action)

    @is_captcha_error = !is_success
    is_success
  end

private

  def verify_google_captcha action
    if Shikimori::IS_RECAPTCHA_V3
      auto_success = verify_recaptcha action:,
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

  def verify_turnstile # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    return false if params[:'cf-turnstile-response'].blank?

    cf_response =
      Retryable.retryable tries: 2, on: ALLOWED_EXCEPTIONS, sleep: 1 do
        Faraday.post do |req|
          req.url 'https://challenges.cloudflare.com/turnstile/v0/siteverify'
          req.headers['Content-Type'] = 'application/json'
          req.options.timeout = 15
          req.options.open_timeout = 15
          req.body = {
            secret: Rails.application.secrets.turnstile[:secret_key],
            response: params[:'cf-turnstile-response']
          }.to_json
        end
      end

    JSON.parse(cf_response.body, symbolize_names: true)[:success]
  rescue JSON::ParserError
    true
  end
end
