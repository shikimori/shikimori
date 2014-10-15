class ProfilesController < UsersController
  before_action :load_user
  authorize_resource :user, class: User

  def show
  end

  def settings
  end

private
  def load_user
    user = User.find_by nickname: User.param_to(params[:profile_id] || params[:id])
    @resource = UserProfileDecorator.new user
  end
end
