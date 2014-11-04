class ProfilesController < ShikimoriController
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

  #def stats
    #page_title 'Статистика'
  #end

  def edit
    authorize! :edit, @resource
    page_title 'Настройки'
    @page = params[:page] || 'account'
    @resource.email = '' if @resource.email =~ /^generated_/ && params[:action] == 'edit'
  end

  def update
    authorize! :update, @resource

    params[:user][:avatar] = nil if params[:user][:avatar] == 'blank'
    params[:user][:notifications] = params[:user][:notifications].sum {|k,v| v.to_i } + MessagesController::DISABLED_CHECKED_NOTIFICATIONS if params[:user][:notifications].present?

    update_successfull = if params[:user][:password].present?
      if @resource.encrypted_password.present?
        @resource.update_with_password password_params
      else
        @resource.update password: params[:user][:password]
      end
    else
      @resource.update update_params
    end

    if update_successfull
      sign_in @resource, bypass: true if params[:user][:password].present?

      if params[:page] == 'account'
        @resource.ignored_users = []
        @resource.update associations_params
      end

      redirect_to edit_profile_url(@resource, page: params[:page]), notice: 'Изменения сохранены'
    else
      flash[:alert] = 'Изменения не сохранены!'
      edit
      render :edit
    end
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

  def update_params
    params.require(:user).permit(
      :avatar, :nickname, :email, :name, :location, :website,
      :sex, :birth_on, :notifications, :about,
      ignored_user_ids: []
    )
  end

  def associations_params
    params.require(:user).permit ignored_user_ids: []
  end

  def password_params
    params.required(:user).permit(:password, :current_password)
  end
end
