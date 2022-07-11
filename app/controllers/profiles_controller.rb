class ProfilesController < ShikimoriController # rubocop:disable ClassLength
  before_action :fetch_resource
  before_action :set_breadcrumbs
  before_action do
    unless !@view || @view.own_profile?
      @top_menu.current_item = {
        name: :avatar,
        url: @resource.url,
        title: @resource.nickname,
        image_url: @resource.avatar_url(20),
        image_2x_url: @resource.avatar_url(48)
      }
    end
  end

  PARENT_SECTIONS = {
    'password' => 'account',
    'ignored_topics' => 'misc',
    'ignored_users' => 'misc'
  }

  TOPICS_LIMIT = 8
  REVIEWS_LIMIT = 5
  COMMENTS_LIMIT = 20
  VERSIONS_PER_PAGE = 30

  # name location
  USER_PARAMS = %i[
    avatar nickname website sex birth_on about locale
  ] + [{
    ignored_user_ids: [],
    notification_settings: [],
    preferences_attributes: %i[id russian_names russian_genres is_show_age is_view_censored]
  }]

  def show
    og noindex: true if @resource.created_at > 1.year.ago

    if user_signed_in? && @view.own_profile? && @view.show_comments?
      MessagesService
        .new(@resource.object)
        .read_by(
          kind: MessageType::PROFILE_COMMENTED,
          is_read: true,
          touch_user: false
        )
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

  def favorites
    og noindex: true
    og page_title: i18n_t('favorites')

    breadcrumb i18n_t('favorites'), favorites_profile_url(@resource)
    @back_url = favorites_profile_url(@resource) if params[:edit]

    @favorites_view = Profiles::FavoritesView.new(@resource)
    redirect_to @resource.url if @favorites_view.collection.none?
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

  def critiques
    og noindex: true
    og page_title: i18n_io('Critique', :few)

    scope = @resource.topics
      .where(type: Topics::EntryTopics::CritiqueTopic.name)
      .order(created_at: :desc)

    @collection = QueryObjectBase.new(scope)
      .paginate(@page, TOPICS_LIMIT)
      .transform do |topic|
        view = Topics::CritiqueView.new topic, true, false
        view.instance_variable_set :@is_show_comments, false
        view
      end
  end

  def reviews
    og noindex: true
    og page_title: i18n_io('Review', :few)

    scope = @resource.reviews
      .includes(:user, :topics, :anime, :manga)
      .order(created_at: :desc)

    @collection = QueryObjectBase.new(scope)
      .paginate(@page, REVIEWS_LIMIT)
      .transform do |model|
        view = Topics::ReviewView.new model.maybe_topic(locale_from_host), true, false
        view.instance_variable_set :@is_show_comments, false
        view
      end
  end

  def collections
    @state = params[:state] || 'published'

    og noindex: true
    og page_title: i18n_io('Collection', :few)
    og notice: i18n_t("collections.#{@state}")

    scope = @resource.topics
      .where(type: Topics::EntryTopics::CollectionTopic.name)
      .joins('left join collections on collections.id = linked_id')
      .order(created_at: :desc)

    @available_states = can?(:access_collections, @resource) ?
      %w[private opened unpublished] :
      %w[opened]

    @counts = scope.except(:order).group('collections.state').count

    scope =
      if @state.in?(@available_states)
        scope.where(collections: { state: @state })
      else
        scope.where(collections: { state: :published })
      end

    @collection = QueryObjectBase.new(scope)
      .paginate(@page, TOPICS_LIMIT)
      .transform { |topic| Topics::TopicViewFactory.new(true, true).build topic }
  end

  def articles
    og noindex: true
    og page_title: i18n_io('Article', :few)

    scope = @resource.topics
      .where(type: Topics::EntryTopics::ArticleTopic.name)
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
      .where(params[:phrase].present? ?
        "body ilike #{ApplicationRecord.sanitize "%#{params[:phrase]}%"}" :
        nil)
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
      .paginate(@page, VERSIONS_PER_PAGE)
      .transform(&:decorate)
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

    if PARENT_SECTIONS[params[:section]]
      og page_title: t("profiles.page.pages.#{PARENT_SECTIONS[params[:section]]}")
      breadcrumb(
        # t("profiles.page.pages.#{PARENT_SECTIONS[params[:page]]}"),
        t(:settings),
        @resource.edit_url(section: PARENT_SECTIONS[params[:section]])
      )
    end
    og page_title: t("profiles.page.pages.#{params[:section]}") rescue I18n::MissingTranslation

    @section = params[:section]
    @resource.email = '' if @resource.generated_email? && params[:action] == 'edit'
  end

  def update # rubocop:disable AbcSize
    authorize! :update, @resource

    params[:user][:avatar] = nil if params[:user][:avatar] == 'blank'

    if update_profile
      bypass_sign_in @resource if params[:user][:password].present?

      params[:section] = 'account' if params[:section] == 'password'
      redirect_to @resource.edit_url(section: params[:section]),
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
        return redirect_to current_url(id_key => nickname_change.user.to_param),
          status: :moved_permanently
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
    breadcrumb i18n_t('user_profile'), @resource.url

    og page_title: i18n_t('profile')
    og page_title: @resource.nickname
  end

  def update_params
    params
      .require(:user)
      .permit(*USER_PARAMS)
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
