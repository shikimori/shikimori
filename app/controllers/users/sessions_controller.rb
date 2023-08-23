class Users::SessionsController < Devise::SessionsController
  include CaptchaConcern
  skip_before_action :verify_authenticity_token
  prepend_before_action :check_captcha, only: %i[create] # rubocop:disable LexicallyScopedActionFilter

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || super
  end

private

  def check_captcha
    unless valid_captcha?('sign_in')
      self.resource = resource_class.new sign_in_params
      # resource.validate # Look for any other validation errors besides Recaptcha
      respond_with_navigational(resource) { render :new }
    end
  end
end
