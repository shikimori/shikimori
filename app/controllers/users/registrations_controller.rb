class Users::RegistrationsController < Devise::RegistrationsController
  include ApplicationHelper
  prepend_before_action :check_captcha, only: %i[create] # rubocop:disable LexicallyScopedActionFilter

  def update
    if resource.update params[resource_name]
      set_flash_message :notice, :updated
      redirect_to profile_path resource
    else
      clean_up_passwords resource
      render 'edit'
    end
  end

private

  def sign_up_params
    params.require(:user).permit :nickname, :password, :email
  end

  def sign_in_params
    params.require(:user).permit :nickname, :password
  end

  def check_captcha
    auto_success = verify_recaptcha action: 'sign_up', minimum_score: 0.25,
      secret_key: Rails.application.secrets.recaptcha[:v3][:secret_key]
    checkbox_success = verify_recaptcha unless auto_success

    unless auto_success || checkbox_success
      @show_checkbox_recaptcha = true
      self.resource = resource_class.new sign_up_params
      # disabled because of expensive email validation
      # resource.validate # Look for any other validation errors besides Recaptcha
      set_minimum_password_length
      respond_with_navigational(resource) { render :new }
    end
  end
end
