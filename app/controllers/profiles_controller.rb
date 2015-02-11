class ProfilesController < ShikimoriController
  before_action :fetch_resource
  before_action :set_breadcrumbs, if: -> { params[:action] != 'show' || params[:controller] != 'profile' }

  page_title 'Профиль'

  def show
    if user_signed_in? && current_user.id == @resource.id
      MessagesService.new(@resource).read_messages(kind: MessageType::ProfileCommented)
    end
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

  def feed
    redirect_to @resource.url if !@resource.show_comments? || @resource.main_thread.comments.count.zero?
    page_title 'Лента'
  end

  #def stats
    #page_title 'Статистика'
  #end

  def reviews
    collection = postload_paginate(params[:page], 5) do
      @resource.reviews.order(id: :desc)
    end

    @collection = collection.map do |review|
      TopicDecorator.new review.thread
    end

    page_title 'Рецензии'
  end

  def comments
    collection = postload_paginate(params[:page], 20) do
      Comment
        .where(user: @resource)
        .where(params[:search].present? ?
          "body ilike #{ActiveRecord::Base.sanitize "%#{SearchHelper.unescape params[:search]}%"}" :
          nil)
        .order(id: :desc)
    end
    @collection = collection.map {|v| SolitaryCommentDecorator.new v }

    page_title 'Комментарии'
  end

  def comments_reviews
    collection = postload_paginate(params[:page], 20) do
      Comment
        .where(user: @resource, review: true)
        .order(id: :desc)
    end
    @collection = collection.map {|v| SolitaryCommentDecorator.new v }

    page_title 'Отзывы'
  end

  def changes
    @collection = postload_paginate(params[:page], 30) do
      @resource.user_changes.order(id: :desc)
    end

    page_title 'Правки контента'
  end

  def videos
    @collection = postload_paginate(params[:page], 30) do
      AnimeVideoReport
        .where(user: @resource)
        .includes(:user, anime_video: :author)
        .order(id: :desc)
    end

    page_title 'Видео загрузки и правки'
  end

  def ban
    @ban = Ban.new user_id: @resource.id
    page_title 'История банов'
  end

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

    update_successfull = if params[:user][:password].present? || params[:user][:email].present?
      if @resource.encrypted_password.present?
        @resource.update_with_password password_params
      else
        @resource.update password_params
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
    user = User.find_by! nickname: User.param_to(params[:profile_id] || params[:id])
    @resource = @user = UserProfileDecorator.new user

    page_title @resource.nickname
  end

  def set_breadcrumbs
    breadcrumb 'Пользователи', users_url
    breadcrumb @resource.nickname, @resource.url
  end

  def update_params
    params.require(:user).permit(
      :avatar, :nickname, :name, :location, :website,
      :sex, :birth_on, :notifications, :about,
      ignored_user_ids: []
    )
  end

  def associations_params
    params.require(:user).permit ignored_user_ids: []
  end

  def password_params
    params.required(:user).permit(:password, :current_password, :email)
  end
end
