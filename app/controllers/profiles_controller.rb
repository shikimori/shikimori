class ProfilesController < UsersController
  before_action :load_user
  authorize_resource :user, class: User
  page_title 'Профиль'

  def show
  end

  def friends
    page_title 'Друзья'
  end

  def clubs
    page_title 'Клубы'
  end

  def favourites
    page_title 'Избранное'
  end

  def history
    page_title 'История'
  end

  def stats
    page_title 'Статистика'
  end

  def settings
    raise NotImplemented
  end

private
  def load_user
    user = User.find_by nickname: User.param_to(params[:profile_id] || params[:id])
    @resource = UserProfileDecorator.new user

    page_title @resource.nickname
  end
end
