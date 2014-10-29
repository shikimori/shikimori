class ProfilesController < ShikimoriController
  HISTORIES_PER_PAGE = 90

  before_action :fetch_resource
  before_action :set_breadcrumbs, if: -> { params[:action] != 'show' }
  #authorize_resource :user, class: User
  page_title 'Профиль'

  def show
  end

  def friends
    redirect_to @resource.url if @resource.friends.none?
    page_title 'Друзья'
  end

  def clubs
    redirect_to @resource.url if @resource.clubs.none?
    page_title 'Клубы'
  end

  def favourites
    redirect_to @resource.url if @resource.favourites.none?
    page_title 'Избранное'
  end

  def history
    redirect_to @resource.url unless @resource.history.any?
    authorize! :see_list, @resource

    @page = (params[:page] || 1).to_i
    @collection, @add_postloader =
      UserHistoryQuery.new(@resource).postload(@page, HISTORIES_PER_PAGE)

    page_title 'История'
  end

  #def stats
    #page_title 'Статистика'
  #end

  def edit
    page_title 'Настройки'
    authorize! :edit, @resource
    @page ||= params[:page] || 'account'
  end

  def update
    authorize! :update, @resource
  end

private
  def fetch_resource
    user = User.find_by nickname: User.param_to(params[:profile_id] || params[:id])
    @resource = UserProfileDecorator.new user

    page_title @resource.nickname
  end

  def set_breadcrumbs
    breadcrumb 'Пользователи', users_url
    breadcrumb @resource.nickname, @resource.url
  end
end
