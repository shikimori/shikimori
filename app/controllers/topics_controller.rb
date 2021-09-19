# TODO: move forum topics actions to Forum::TopicsController other actions should stay here
class TopicsController < ShikimoriController
  before_action :check_post_permission, only: %i[create update destroy]

  load_and_authorize_resource class: Topic, only: %i[new create update destroy]
  load_resource class: Topic, only: %i[edit]

  before_action :fetch_topic, only: %i[show tooltip]
  before_action :set_view
  before_action :set_breadcrumbs
  before_action :set_canonical, only: %i[show]

  UPDATE_PARAMS = %i[body title linked_id linked_type tags]
  CREATE_PARAMS = UPDATE_PARAMS + %i[user_id forum_id type]

  def index # rubocop:disable AbcSize
    og noindex: true if params[:search].present?

    if params[:linked_id]
      # редирект на топик, если топик в подфоруме единственный
      if @forums_view.topic_views.one?
        ensure_redirect! UrlGenerator.instance.topic_url(@forums_view.topic_views.first.topic)
      end

      # редирект, исправляющий linked
      ensure_redirect! UrlGenerator.instance.forum_url(@forums_view.forum, @forums_view.linked)

      raise ForceRedirect, @forums_view.current_page_url if @forums_view.linked.is_a?(Club)
    end
  end

  def show
    # новости аниме без комментариев поисковым системам не скармливаем
    return render :missing if @resource.is_a? NoTopic
    return redirect_to @forums_view.redirect_url if @forums_view.hidden?

    raise AgeRestricted if @resource&.linked.try(:censored?) && censored_forbidden?

    ensure_redirect! UrlGenerator.instance.topic_url(@resource)
  end

  def new
    topic_type_policy = Topic::TypePolicy.new(@resource)
    topic_type =
      if @resource.forum == Forum.critiques
        :critique
      elsif @resource.forum == Forum.articles
        :article
      elsif topic_type_policy.news_topic?
        :news
      else
        :topic
      end

    og(
      page_title: i18n_t("new_#{topic_type}")
    )
  end

  def edit
    ensure_redirect! @topic_view.urls.edit_url if params[:action] == 'edit'
    authorize! :edit, @resource
  end

  def create
    @resource = Topic::Create.call(
      faye: faye,
      params: topic_params,
      locale: locale_from_host
    )

    if @resource.persisted?
      redirect_to(
        UrlGenerator.instance.topic_url(@resource),
        notice: i18n_t('topic.created')
      )
    else
      new
      flash[:alert] = t('changes_not_saved')
      render :new
    end
  end

  def update
    is_updated = Topic::Update.call(
      topic: @resource,
      params: topic_params,
      faye: faye
    )

    if is_updated
      redirect_to(
        UrlGenerator.instance.topic_url(@resource),
        notice: i18n_t('topic.updated')
      )
    else
      edit
      flash[:alert] = t('changes_not_saved')
      render :edit
    end
  end

  def destroy
    faye.destroy @resource
    render json: { notice: i18n_t('topic.deleted') }
  end

  def tooltip
    og noindex: true
    return render :missing if @resource.is_a? NoTopic

    @topic_view = Topics::TopicViewFactory.new(true, true).find params[:id]

    if request.xhr?
      render(
        partial: 'topics/topic',
        object: @topic_view,
        as: :topic_view,
        layout: false,
        formats: :html
      )
    else
      render :show
    end
  end

  # выбранные топики
  def chosen
    @collection = Topic
      .where(id: params[:ids].split(',').map(&:to_i))
      .map { |topic| Topics::TopicViewFactory.new(true, false).build topic }

    render :collection, formats: :json
  end

  # подгружаемое через ajax тело топика
  def reload
    topic = Topic.find params[:id]
    @topic_view = Topics::TopicViewFactory
      .new(params[:is_preview] == 'true', false)
      .build(topic)

    render :show, formats: :json
  end

private

  def topic_params # rubocop:disable all
    allowed_params =
      if can?(:manage, Topic) || %w[new create].include?(params[:action])
        CREATE_PARAMS
      else
        UPDATE_PARAMS
      end
    allowed_params += [:broadcast] if can? :broadcast, Topic
    allowed_params += [:is_closed] if can? :close, Topic
    allowed_params += [:is_pinned] if can? :promote, Topic

    params.require(:topic).permit(*allowed_params).tap do |fixed_params|
      fixed_params[:body] = Topics::ComposeBody.call(params[:topic])

      unless fixed_params[:tags].nil?
        fixed_params[:tags] = fixed_params[:tags].split(',').map(&:strip).select(&:present?)
      end
    end
  end

  def set_view
    @forums_view = Forums::View.new params[:forum]

    if %w[show edit].include?(params[:action]) && @resource
      @topic_view = Topics::TopicViewFactory.new(false, false).build @resource
    end
  end

  def set_breadcrumbs
    og page_title: t('page', page: @page) if @page > 1
    og page_title: i18n_t('title')
    breadcrumb t('forum'), forum_url

    if @resource&.forum
      og page_title: @resource.forum.name
      breadcrumb @resource.forum.name, forum_topics_url(@resource.forum)

      if @forums_view.linked
        breadcrumb(
          UsersHelper.localized_name(@forums_view.linked, current_user),
          UrlGenerator.instance.forum_url(
            @forums_view.forum, @forums_view.linked
          )
        )
      end

      og page_title: @topic_view ? @topic_view.topic_title : @resource.title
      if %w[edit update].include? params[:action]
        breadcrumb(
          @topic_view ? @topic_view.topic_title : @resource.title,
          UrlGenerator.instance.topic_url(@resource)
        )
      end

    elsif @forums_view.forum
      og page_title: @forums_view.forum.name
      if params[:action] != 'index' || @forums_view.linked
        breadcrumb @forums_view.forum.name, forum_topics_url(@forums_view.forum)
      end

      if @forums_view.linked
        og(
          page_title: UsersHelper.localized_name(
            @forums_view.linked,
            current_user
          )
        )
      end
    end
  end

  def fetch_topic
    topic = Topic.find_by(id: params[:id])
    raise ActiveRecord::RecordNotFound if request.format.rss?

    @resource = topic || NoTopic.new(id: params[:id].to_i)
  end

  def set_canonical
    @canonical = @topic_view&.canonical_url # can be nil when topic is a NoTopic
  end

  def faye
    FayeService.new current_user, faye_token
  end

  def noindex?
    @resource.is_a?(NoTopic) ||
      (@resource.generated? && @resource.comments_count.zero?)
  end

  def copyrighted_resource_id_key
    :linked_id
  end
end
