class ProfilesController < UsersController
  before_action :load_user
  authorize_resource :user, class: User

  def show
  end

  def settings
  end

private
  def load_user
    @resource = UserProfileDecorator.new User.find_by(nickname: params[:profile_id] || params[:id])
  end
end
