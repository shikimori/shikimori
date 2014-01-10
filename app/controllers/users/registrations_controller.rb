class Users::RegistrationsController < Devise::RegistrationsController
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
end
