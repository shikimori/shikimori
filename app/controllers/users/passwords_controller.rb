class Users::PasswordsController < Devise::PasswordsController
  include ApplicationHelper
  prepend_before_action :check_captcha, only: %i[create] # rubocop:disable LexicallyScopedActionFilter
  skip_before_action :require_no_authentication

  def new
    email = params.dig(:user, :email)
    if email.present?
      self.resource = resource_class.new email: email
    else
      super
    end
  end

  def update
    super do |user|
      bypass_sign_in user if user.errors.none?
    end
  end

private

  def check_captcha
    unless verify_recaptcha
      self.resource = resource_class.new
      # resource.validate # Look for any other validation errors besides Recaptcha
      respond_with_navigational(resource) { render :new }
    end
  end
end
