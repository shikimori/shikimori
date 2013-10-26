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
end
