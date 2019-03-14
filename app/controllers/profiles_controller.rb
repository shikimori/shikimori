class ProfilesController < ShikimoriController # rubocop:disable ClassLength
  before_action :fetch_resource
  before_action :set_breadcrumbs

  PARENT_PAGES = {
    'password' => 'account',
    'ignored_topics' => 'misc',
    'ignored_users' => 'misc'
  }

  TOPICS_LIMIT = 8
  COMMENTS_LIMIT = 20
  VERSIONS_LIMIT = 30

  def show
    og noindex: true if @resource.created_at > 1.year.ago

    if user_signed_in? && current_user.id == @resource.id
      MessagesService
        .new(@resource.object)
        .read_messages(kind: MessageType::PROFILE_COMMENTED)
    end
  end

  def friends
    og noindex: true
    og page_title: i18n_t('friends')
    redirect_to @resource.url if @resource.friends.none?
  end

  def clubs
    og noindex: true
    og page_title: i18n_i('Club', :other)
    redirect_to @resource.url if @resource.clubs.none?
  end

  def favourites
    og noindex: true
    og page_title: i18n_t('favorites')
    redirect_to @resource.url if @resource.favourites.none?
  end

  def feed
    og noindex: true
    og page_title: i18n_t('feed')

    if !@view.show_comments? ||
        @resource.main_comments_view.comments_count.zero?
      redirect_to @resource.url
    end
  end

  # def stats
    # page_title 'Статистика'
  # end

  def topics
    og noindex: true
    og page_title: i18n_io('Topic', :few)

    scope = @resource.topics.user_topics.order(created_at: :desc)

    @collection = QueryObjectBase.new(scope)
      .paginate(@page, TOPICS_LIMIT)
      .transform { |topic| Topics::TopicViewFactory.new(true, true).build topic }
  end

  def reviews
    og noindex: true
    og page_title: i18n_io('Review', :few)

    scope = @resource.topics
      .where(type: Topics::EntryTopics::ReviewTopic.name)
      .order(created_at: :desc)

    @collection = QueryObjectBase.new(scope)
      .paginate(@page, TOPICS_LIMIT)
      .transform { |topic| Topics::TopicViewFactory.new(true, true).build topic }
  end

  def collections
    og noindex: true
    og page_title: i18n_io('Collection', :few)

    scope = @resource.topics
      .where(type: Topics::EntryTopics::CollectionTopic.name)
      .order(created_at: :desc)

    @collection = QueryObjectBase.new(scope)
      .paginate(@page, TOPICS_LIMIT)
      .transform { |topic| Topics::TopicViewFactory.new(true, true).build topic }
  end

  def comments
    og noindex: true
    og page_title: i18n_io('Comment', :few)

    scope = Comment
      .where(user: @resource.object)
      .where(params[:search].present? ?
        "body ilike #{ApplicationRecord.sanitize "%#{params[:search]}%"}" :
        nil)
      .order(id: :desc)

    @collection = QueryObjectBase.new(scope)
      .paginate(@page, COMMENTS_LIMIT)
      .transform { |comment| SolitaryCommentDecorator.new comment }
  end

  def summaries
    og noindex: true
    og page_title: i18n_io('Summary', :few)

    scope = Comment
      .where(user: @resource.object, is_summary: true)
      .order(id: :desc)

    @collection = QueryObjectBase.new(scope)
      .paginate(@page, COMMENTS_LIMIT)
      .transform { |comment| SolitaryCommentDecorator.new comment }
  end

  def versions
    og noindex: true
    og page_title: i18n_io('Content_change', :few)

    scope = @resource.versions
      .where.not(item_type: AnimeVideo.name)
      .order(id: :desc)

    @collection = QueryObjectBase.new(scope)
      .paginate(@page, VERSIONS_LIMIT)
      .transform(&:decorate)
  end

  def video_versions
    og noindex: true
    og page_title: i18n_io('Video_change', :few)

    scope = @resource.versions
      .where(item_type: AnimeVideo.name)
      .order(id: :desc)

    @collection = QueryObjectBase.new(scope)
      .paginate(@page, VERSIONS_LIMIT)
      .transform(&:decorate)
  end

  def video_uploads
    og noindex: true
    og page_title: i18n_io('Video_upload', :few)

    scope = AnimeVideoReport
      .where(user: @resource.object)
      .where(kind: :uploaded)
      .includes(:user, anime_video: :author)
      .order(id: :desc)

    @collection = QueryObjectBase.new(scope).paginate(@page, VERSIONS_LIMIT)
  end

  def video_reports
    og noindex: true
    og page_title: i18n_io('Video_report', :few)

    scope = AnimeVideoReport
      .where(user: @resource.object)
      .where.not(kind: :uploaded)
      .includes(:user, anime_video: :author)
      .order(id: :desc)

    @collection = QueryObjectBase.new(scope).paginate(@page, VERSIONS_LIMIT)
  end

  def moderation
    og noindex: true
    if can? :manage, Ban
      og page_title: t('profiles.show.moderation')
    else
      og page_title: t('profiles.show.ban_history')
    end

    @ban = Ban.new user_id: @resource.id
  end

  def edit # rubocop:disable AbcSize
    authorize! :edit, @resource
    og page_title: t(:settings)

    if PARENT_PAGES[params[:page]]
      og page_title: t("profiles.page.pages.#{PARENT_PAGES[params[:page]]}")
      breadcrumb(
        # t("profiles.page.pages.#{PARENT_PAGES[params[:page]]}"),
        t(:settings),
        @resource.edit_url(page: PARENT_PAGES[params[:page]])
      )
    end
    og page_title: t("profiles.page.pages.#{params[:page]}") rescue I18n::MissingTranslation

    @page = params[:page]
    @resource.email = '' if @resource.email =~ /^generated_/ && params[:action] == 'edit'
  end

  def update # rubocop:disable AbcSize
    authorize! :update, @resource

    params[:user][:avatar] = nil if params[:user][:avatar] == 'blank'

    if update_profile
      bypass_sign_in @resource if params[:user][:password].present?

      params[:page] = 'account' if params[:page] == 'password'
      redirect_to @resource.edit_url(page: params[:page]),
        notice: t('changes_saved')
    else
      flash[:alert] = t('changes_not_saved')
      edit
      render :edit
    end
  end

private

  def fetch_resource
    nickname = User.param_to(params[:profile_id] || params[:id])
    user = User.find_by nickname: nickname

    unless user
      nickname_change = UserNicknameChange.where(value: nickname).order(:id).first

      if nickname_change
        id_key = params[:profile_id] ? :profile_id : :id
        return redirect_to current_url(id_key => nickname_change.user.to_param), status: 301
      else
        raise ActiveRecord::RecordNotFound, nickname
      end
    end

    @resource = UserProfileDecorator.new user
    @user = @resource
    @view = Profiles::View.new @resource

    if @resource.censored_profile? && censored_forbidden? &&
        !@view.own_profile?
      raise AgeRestricted
    end
  end

  def set_breadcrumbs
    breadcrumb i18n_i('User', :other), users_url
    breadcrumb @resource.nickname, @resource.url

    og page_title: i18n_t('profile')
    og page_title: @resource.nickname

    @top_menu.add_user_item @resource
  end

  def update_params
    params.require(:user).permit(
      :avatar, :nickname, :name, :location, :website,
      :sex, :birth_on, :about, :locale,
      ignored_user_ids: [],
      notification_settings: [],
      preferences_attributes: %i[id russian_names russian_genres]
    )
  end

  def password_params
    params.required(:user).permit(:password, :current_password, :email)
  end

  def update_profile
    if params[:user][:password].present? || params[:user][:email].present?
      if @resource.encrypted_password.present?
        @resource.update_with_password password_params
      else
        @resource.update password_params.except('current_password')
      end
    else
      @resource.update(
        update_params[:nickname].blank? ?
          update_params.merge(nickname: @resource.nickname) :
          update_params
      )
    end
  rescue PG::UniqueViolation, ActiveRecord::RecordNotUnique
    @resource.errors.add :nickname, :taken
    false
  end
end
