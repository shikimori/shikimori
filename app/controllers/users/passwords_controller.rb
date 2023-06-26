class Users::PasswordsController < Devise::PasswordsController
  include CaptchaConcern
  include ApplicationHelper
  prepend_before_action :check_captcha, only: %i[create] # rubocop:disable LexicallyScopedActionFilter
  skip_before_action :require_no_authentication

  def new
    if email_param.present?
      self.resource = resource_class.new email: email_param
    else
      super
    end
  end

  def update
    super do |user|
      bypass_sign_in user if user.errors.none? && user_signed_in?
    end
  end

private

  def email_param
    params.dig(:user, :email)
  end

  def after_sending_reset_password_instructions_path_for(resource_name)
    if user_signed_in?
      edit_profile_url current_user, section: :account
    else
      super
    end
  end

  def check_captcha
    unless valid_captcha?('forgot')
      self.resource = resource_class.new email: email_param
      # resource.validate # Look for any other validation errors besides Recaptcha
      respond_with_navigational(resource) { render :new }
    end
  end
end
