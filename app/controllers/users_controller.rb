require "digest"

# TODO: отрефакторить толстый контроллер
# TODO: users#show вынести в ProfilesController
class UsersController < ApplicationController
  include MessagesHelper # для работы хелпера format_linked_name
  include TopicsHelper # для работы MesasgesHelper - topic_url там хелпер
  include ActionView::Helpers::SanitizeHelper

  respond_to :json, only: :autocomplete
  respond_to :json, :html, only: :index

  before_filter :authenticate_user!, only: [:settings, :update, :remove_provider, :ban, :do_ban]
  before_filter :prepare, except: [:index, :similar, :search, :autocomplete]

  @@messages_pages = ['inbox', 'news', 'notifications', 'sent']
  @@ani_manga_list_pages = ['animelist', 'mangalist']

  helper_method :message_types
  helper_method :unread_counts

  UsersPerPage = 15
  Thresholds = [25, 50, 100, 175, 350]

  # список всех пользователей
  def index
    if params[:similar]
      @threshold = params[:threshold].to_i
      @klass = params[:klass] == Manga.name.downcase ? Manga : Anime
      @page = (params[:page] || 1).to_i

      unless Thresholds.include?(@threshold)
        redirect_to(params.merge threshold: Thresholds[2])
        return
      end

      @page_title = 'Похожие пользователи'
      @similar_ids = SimilarUsersFetcher.new(current_user, @klass, @threshold).fetch

      if @similar_ids
        ids = @similar_ids
            .drop(UsersPerPage * (@page - 1))
            .take(UsersPerPage)

        @users = User.where(id: ids).sort_by {|v| ids.index v.id }
      end

      @add_postloader = @similar_ids && @similar_ids.any? && @page * UsersPerPage < SimilarUsersService::ResultsLimit

    else
      @page_title = 'Пользователи'
      @users = postload_paginate(params[:page], UsersPerPage) do
        if params[:search]
          search = "%#{params[:search]}%"
          User.where { nickname.like(search) }.order(:nickname)
        else
          User.where { id.not_eq(1) }.order('if(last_online_at>current_sign_in_at,last_online_at,current_sign_in_at) desc')
        end
      end

      @users = @users.sort_by {|v| v.last_online_at }.reverse
    end

    UserPresenter.fill_users_history @users, current_user if @users
  end

  # поиск пользователей
  def search
    redirect_to users_path(search: params[:search])
  end

  # отображение информации о пользователе
  def show
    @messages_pages = @@messages_pages
    @ani_manga_list_pages = @@ani_manga_list_pages
    @pages = ['statistics', 'friends', 'comments', 'reviews', 'changes', 'favourites', 'clubs', 'settings', 'list-history', @@messages_pages, 'talk', 'notifications-settings'] +
        (user_signed_in? && current_user.moderator? ? ['ban'] : []) +
        @@ani_manga_list_pages
    #@pages = ['profile', 'friends', 'favourites', 'topics', 'settings', @messages_pages, 'new-message', 'talk', 'notifications-settings'] + @ani_manga_list_pages
    @sub_layout = 'user'

    if params.include?(:comment_id)
      comment = Comment.where(user_id: @user.id).find(params[:comment_id])
      @reply_text = "[quote]#{comment.body}[/quote]&nbsp;"
    end

    raise ActiveRecord::RecordNotFound.new('user not found') unless @user
    @page_title ||= UsersController.profile_title(nil, @user)

    # если заходим в собственный профиль, и есть уведомления о новых сообщениях в профиле, то помечаем их прочитанными
    if params[:type] == 'statistics' && user_signed_in? && current_user.id == @user.id
      Message.where(dst_id: current_user.id, dst_type: User.name, kind: MessageType::ProfileCommented, read: false).each do |v|
        v.update_attribute(:read, true)
      end
    end

    if params[:format] != 'rss'
      @with_compatibility = false
    end

    @genres, @studios, @publishers = AniMangaAssociationsQuery.new.fetch

    # совместимость
    if user_signed_in? && current_user.id != @user.id
      @compatibility = CompatibilityService.fetch @user, current_user
    end

    @favourites = (@user.fav_animes.all + @user.fav_mangas.all + @user.fav_characters.all + @user.fav_people.all)
      .shuffle
      .uniq_by { |fav| [fav.id, fav.class] }
      .take(10)
      .sort_by do |fav|
        [fav.class.name == Manga.name ? Anime.name : fav.class.name, fav.name]
      end

    @partial = "#{params[:controller]}/%s" % [
      (@@ani_manga_list_pages & [params[:type], "#{params[:list_type] || ""}-#{params[:type]}"]).any? ?
        'ani_manga_list' : params[:type]
    ]
    @presenter = present @user

    respond_to do |format|
      format.html { render 'users/show' }
      format.rss { render 'users/show', layout: false, formats: :rss }
      format.json {
        render json: {
          content: render_to_string(partial: @partial, layout: false, formats: :html), title_page: @page_title
        }
      }
    end
  end

  # страница профиля
  def statistics
    @history = @user.all_history.order('updated_at desc').limit(30) if params[:format] == 'rss'
    @kind = (params[:kind] || (@user.preferences.manga_first? ? :manga : :anime)).to_sym

    show
  end

  # список друзей
  def friends
    @page_title = UsersController.profile_title('Друзья', @user)
    show
  end

  # страница бана пользователя
  def ban
    @page_title = UsersController.profile_title('Забанить', @user)

    @ban = Ban.new user_id: @user.id
    show
  end

  # список комментариев
  def comments
    @page_title = UsersController.profile_title('Комментарии', @user)

    @comments = postload_paginate(params[:page], 20) do
      Comment.where(user_id: @user.id).order('id desc')
    end

    @comments.each do |comment|
      formatted = format_linked_name(comment.commentable_id, comment.commentable_type, comment.id)

      comment[:topic_name] = '<span class="normal">'+formatted.match(/^(.*?)</)[1] + "</span> " + sanitize(formatted.match(/>(.*?)</)[1])
      comment[:topic_url] = formatted.match(/href="(.*?)"/)[1]
    end

    respond_to do |format|
      format.html { show }
      format.json do
        render json: { content: render_to_string(partial: 'users/comments', layout: false, formats: :html) }
      end
    end
  end

  # список обзоров
  def reviews
    @page_title = UsersController.profile_title('Обзоры', @user)
    @reviews = postload_paginate(params[:page], 10) do
      @user
        .reviews
        .includes(:user, :votes, :thread)
        .with_viewed(current_user)
        .order('entries.updated_at desc')
    end.map do |review|
      TopicPresenter.new({
        object: review.thread,
        template: view_context,
        linked: review,
        blocked_rel: true,
        limit: 2
      })
    end

    show
  end

  # клубы пользователя
  def clubs
    @page_title = UsersController.profile_title('Клубы', @user)
    @clubs = @user
        .groups
        .joins(:member_roles, :thread)
        .group('groups.id')
        .order(comments: 'updated_at desc')
    show
  end

  # список правок
  def changes
    @page_title = UsersController.profile_title('Правки', @user)

    @changes = postload_paginate(params[:page], 25) do
      UserChange.where(user_id: @user.id).order('id desc')
    end

    respond_to do |format|
      format.html { show }
      format.json do
        render json: { content: render_to_string(partial: 'users/changes', layout: false, formats: :html) }
      end
    end
  end

  # список любимых аниме, персонажей и т.д.
  def favourites
    @page_title = UsersController.profile_title('Избранное', @user)
    show
  end

  # отображение списка топиков пользователя
  def topics
    @page_title = UsersController.profile_title('Блог', @user)

    show
  end

  # настройки
  def settings
    raise Forbidden unless user_signed_in? && @user.can_be_edited_by?(current_user)
    @page_title = UsersController.profile_title('Настройки', @user)
    @months = [ [0, ''], [1, 'Январь'], [2, 'Февраль'], [3, 'Март'], [4, 'Апрель'], [5, 'Май'], [6, 'Июнь'], [7, 'Июль'], [8, 'Август'], [9, 'Сентябрь'], [10, 'Октябрь'], [11, 'Ноябрь'], [12, 'Декабрь'] ]
    @user.preferences.statistics_start_on ||= @user.created_at.to_date
    @user.email = '' if @user.email =~ /generated_/

    params[:page] ||= 'account'
    params[:user] = {} unless params[:user]

    show
  end

  # смена пароля
  def update_password
    raise Forbidden unless @user.can_be_edited_by? current_user

    if params[:user][:password].present?
      change_successfull = if @user.encrypted_password.present?
        @user.update_with_password params.required(:user).permit(:password, :password_confirmation, :current_password)
      else
        @user.password = params[:user][:password]
        @user.save
      end

      if change_successfull
        sign_in @user, bypass: true
        redirect_to user_settings_path(@user), notice: 'Ваш пароль изменён'
        return
      end
    end

    flash[:alert] = 'Пароль не изменён!'
    params[:type] = 'settings'
    params[:page] = 'password'
    show
  end

  # обновление данных профиля пользователя
  def update
    raise Forbidden unless @user.can_be_edited_by? current_user

    params[:user][:avatar] = nil if params[:user][:avatar] == 'blank'
    params[:user].delete(:nickname) if params[:user][:nickname].blank?
    params[:user][:notifications] = params[:user][:notifications].sum {|k,v| v.to_i } + MessagesController::DISABLED_CHECKED_NOTIFICATIONS if params[:user][:notifications].present?

    if params[:user][:ignores].present?
      @user.ignored_users = []

      params[:user][:ignores].select {|v| !v.blank? }.take(20).each do |v|
        @user.ignores.create! target_id: User.find_by_nickname(v).id
      end
    end

    if @user.update_attributes user_params
      redirect_to user_settings_path(@user, params[:page]), notice: 'Изменения сохранены'
    else
      flash[:alert] = 'Изменения не сохранены!'
      params[:type] = 'settings'
      show
    end

    #if @user.errors.empty? && @user.save && @user.preferences.save
      #if params[:user].include? 'password'
        #sign_out @user
        #@user.remember_me = true
        #sign_in :user, @user
      #end

      #respond_to do |format|
        #format.html { redirect_to(params[:user]['nickname'] ? user_settings_url(@user) : :back) }
        #format.json {
          #render json: {success: true,
                           #content: render_to_string(partial: 'users/card',
                                                        #layout: false,
                                                        #locals: {user: @user},
                                                        #formats: :html)}
        #}
      #end
    #else
      #respond_to do |format|
        #format.html {
          #params[:type] = 'settings'
          #flash[:alert] = @user.errors.map {|k,v| "#{k.to_s.capitalize} #{v}"}.join '<br />'
          #settings
        #}
        #format.json { render json: @user.errors, status: :unprocessable_entity }
      #end
    #end

    #raise 'not implemented yet'

    #@user.preferences.anime = false
    #@user.preferences.anime_genres = false
    #@user.preferences.anime_studios = false
    #@user.preferences.manga = false
    #@user.preferences.manga_genres = false
    #@user.preferences.manga_publishers = false
    #@user.preferences.genres_graph = false
    #@user.preferences.clubs = false
    #@user.preferences.comments = false
    #@user.preferences.statistics = false
    #@user.preferences.postload_in_catalog = false
    #@user.preferences.manga_first = false
    #@user.preferences.russian_names = false
    #@user.preferences.russian_genres = false
    #@user.preferences.about_on_top = false
    #@user.preferences.mylist_in_catalog = true
    #@user.preferences.menu_contest = false
    #@user.social = false
    #@user.smileys = false
    #@user.page_border = false

    #@user.preferences.statistics_start_on = params[:user][:statistics_start_on]

    ## TODO: отрефакторить на нормальный simple_form_for
    #params[:user].each do |k,v|
      #k = 'about' if k == 'description'
      #if k == 'password' && !v.blank?
        #if @user.encrypted_password.blank? || @user.valid_password?(params[:user]['password_check'])
          #@user.password = v
        #else
          #@user.errors['Введён'] = 'неверный пароль'
        #end
      #elsif k == 'birth_on'
        #if v['year'].to_i > 0
          #@user.birth_on = DateTime.new(v['year'].to_i, [v['month'].to_i, 1].max, [v['day'].to_i, 1].max)
        #else
          #@user.birth_on = nil
        #end
      #elsif k == 'avatar'
        #@user.avatar = v.blank? ? nil : v
      #elsif k == 'social'
        #@user.social = true
      #elsif k == 'page_border'
        #@user.page_border = true
      #elsif k == 'smileys'
        #@user.smileys = true
      #elsif k == 'anime'
        #@user.preferences.anime = true
      #elsif k == 'anime_genres'
        #@user.preferences.anime_genres = true
      #elsif k == 'anime_studios'
        #@user.preferences.anime_studios = true
      #elsif k == 'manga'
        #@user.preferences.manga = true
      #elsif k == 'manga_genres'
        #@user.preferences.manga_genres = true
      #elsif k == 'manga_publishers'
        #@user.preferences.manga_publishers = true
      #elsif k == 'genres_graph'
        #@user.preferences.genres_graph = true
      #elsif k == 'clubs'
        #@user.preferences.clubs = true
      #elsif k == 'comments'
        #@user.preferences.comments = true
      #elsif k == 'statistics'
        #@user.preferences.statistics = true
      #elsif k == 'postload_in_catalog'
        #@user.preferences.postload_in_catalog = true
      #elsif k == 'manga_first'
        #@user.preferences.manga_first = true
      #elsif k == 'about_on_top'
        #@user.preferences.about_on_top = true
      #elsif k == 'russian_names'
        #@user.preferences.russian_names = true
      #elsif k == 'russian_genres'
        #@user.preferences.russian_genres = true
      #elsif k == 'mylist_in_catalog'
        #@user.preferences.mylist_in_catalog = true
      #elsif k == 'menu_contest'
        #@user.preferences.menu_contest = true
      #else
        #@user[k] = v
      #end
    #end

    ## уведомления
    #@user.notifications = (params[:notifications] ? params[:notifications].sum {|k,v| v.to_i } : 0) + MessagesController::DISABLED_CHECKED_NOTIFICATIONS

    ## список игнора
    #if params[:ignores]
      #@user.ignored_users = []

      #params[:ignores].select {|v| !v.blank? }.take(20).each do |v|
        #@user.ignores.create!(target_id: User.find_by_nickname(v).id)
      #end
    #end

    #if @user.errors.empty? && @user.save && @user.preferences.save
      #if params[:user].include? 'password'
        #sign_out @user
        #@user.remember_me = true
        #sign_in :user, @user
      #end

      #respond_to do |format|
        #format.html { redirect_to(params[:user]['nickname'] ? user_settings_url(@user) : :back) }
        #format.json {
          #render json: {success: true,
                           #content: render_to_string(partial: 'users/card',
                                                        #layout: false,
                                                        #locals: {user: @user},
                                                        #formats: :html)}
        #}
      #end
    #else
      #respond_to do |format|
        #format.html {
          #params[:type] = 'settings'
          #flash[:alert] = @user.errors.map {|k,v| "#{k.to_s.capitalize} #{v}"}.join '<br />'
          #settings
        #}
        #format.json { render json: @user.errors, status: :unprocessable_entity }
      #end
    #end
  end

  # заголовок для профиля
  def self.profile_title(title, user)
    if title
      ["Профиль #{user.nickname}", title]
    else
      ["Профиль #{user.nickname}"]
    end
  end

  # отмена доступа для определённого сервиса
  def remove_provider
    raise Forbidden unless @user.can_be_edited_by?(current_user)

    if (@user.encrypted_password.blank? || @user.email =~ /^generated_/) && UserToken.where(user_id: @user.id).count == 1
      missed = [@user.email =~ /^generated_/ ? 'e-mail' : nil, @user.encrypted_password.blank? ? 'пароль' : nil].compact
      flash[:alert] = "Вы не сможете отключить единственный способ авторизации, пока не зададите #{missed.join(' и ')}."
      redirect_to :back and return
    end

    UserToken.find_by_user_id_and_provider(@user.id, params[:provider]).destroy
    flash[:notice] = "Отключена авторизация через #{params[:provider].titleize}"
    redirect_to :back
  end

  # автодополнение
  def autocomplete
    @items = UsersQuery.new(params).complete
  end

private
  def prepare
    noindex and nofollow

    if params[:user_id] && Rails.env.development?
      @user = User.find params[:user_id]
      return
    end

    nickname = User.param_to params[:id]
    @user = User.includes(:friends)
                .where(nickname: nickname)
                .select { |v| v.nickname == nickname }
                .first

    raise NotFound, nickname unless @user
  end

  # число прочитанных сообщений
  def unread_counts
    @unread ||= {
      'inbox' => current_user.unread_messages,
      'news' => current_user.unread_news,
      'notifications' => current_user.unread_notifications,
      'sent' => 0
    }
  end

  # типы сообщений
  def message_types
     [
      { id: 'inbox', name: 'Входящее' },
      { id: 'news', name: 'Новости' },
      { id: 'notifications', name: 'Уведомления' },
      { id: 'sent', name: 'Отправленное' }
    ]
  end

  def user_params
    params.require(:user).permit(
      :avatar, :nickname, :email, :name, :location, :website, :sex, :birth_on, :notifications, :about,
      preferences_attributes: [
        :anime_in_profile, :manga_in_profile, :manga_first, :clubs_in_profile,
        :statistics_in_profile, :comments_in_profile, :statistics_start_on,
        :page_background, :page_border, :body_background, :about_on_top, :about
      ]
    )
  end
end
