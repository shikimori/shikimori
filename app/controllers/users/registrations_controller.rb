class Users::RegistrationsController < Devise::RegistrationsController
  include ApplicationHelper
  prepend_before_action :check_captcha, only: [:create]

  def edit
    super
  end

  def update
    if resource.update_attributes(params[resource_name])
      set_flash_message :notice, :updated
      redirect_to profile_path(resource)
    else
      clean_up_passwords(resource)
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
    unless verify_recaptcha
      self.resource = resource_class.new sign_up_params
      # disabled because of expensive email validation
      # resource.validate # Look for any other validation errors besides Recaptcha
      set_minimum_password_length
      respond_with_navigational(resource) { render :new }
    end
  end
end
