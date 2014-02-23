# TODO: вынести сюда весь код из users#show
class ProfilesController < UsersController
  def show
    params[:controller] = 'users'
    params[:type] ||= 'statistics'
    super
  end

  def settings
    params[:type] = 'settings'
    super
  end
end
