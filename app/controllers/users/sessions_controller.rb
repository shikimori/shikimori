class Users::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token
  prepend_before_action :check_captcha, only: %i[create] # rubocop:disable LexicallyScopedActionFilter

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || super
  end

private

  def check_captcha
    auto_success = verify_recaptcha action: 'sign_in', minimum_score: 0.25,
      secret_key: Rails.application.secrets.recaptcha[:v3][:secret_key]
    checkbox_success = verify_recaptcha unless auto_success

    unless auto_success || checkbox_success
      @show_checkbox_recaptcha = true
      self.resource = resource_class.new sign_in_params
      # resource.validate # Look for any other validation errors besides Recaptcha
      respond_with_navigational(resource) { render :new }
    end
  end
end
