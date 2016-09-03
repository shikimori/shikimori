# TODO: move forum topics actions to Forum::TopicsController
# other actions should stay here
class TopicsController < ShikimoriController
  # NOTE: не менять на Topic!. Ломается выбор типа топика при создании топика
  load_and_authorize_resource(
    class: Topic,
    only: %i(new create edit update show destroy)
  )

  before_action :check_post_permission, only: [:create, :update, :destroy]
  before_action :compose_body, only: [:create, :update]
  before_action :set_view
  before_action :set_breadcrumbs

  def index
    # редирект на топик, если топик в подфоруме единственный
    if params[:linked_id] && @forums_view.topic_views.one?
      return redirect_to(
        UrlGenerator.instance.topic_url(
          @forums_view.topic_views.first.topic,
          params[:format]
        ),
        status: 301
      )
    end

    # редирект, исправляющий linked
    if params[:linked_id] && @forums_view.linked.to_param != params[:linked_id]
      return redirect_to(
        UrlGenerator.instance.forum_url(
          @forums_view.forum,
          @forums_view.linked
        ),
        status: 301
      )
    end
  end

  def show
    expected_url = UrlGenerator.instance.topic_url @resource

    if request.url.gsub(/\?.*|https?:/, '') != expected_url &&
        request.format != 'rss'
      return redirect_to expected_url, status: 301
    end

    # новости аниме без комментариев поисковым системам не скармливаем
    noindex && nofollow if @resource.generated? && @resource.comments_count.zero?
    raise AgeRestricted if @resource.linked && @resource.linked.try(:censored?) && censored_forbidden?
  end

  def new
    noindex

    topic_type_policy = Topic::TypePolicy.new(@resource)
    page_title i18n_t("new_#{topic_type_policy.news_topic? ? :news : :topic}")
    @back_url = @breadcrumbs[@breadcrumbs.keys.last]
  end

  def edit
  end

  def create
    if faye.create @resource
      redirect_to UrlGenerator.instance.topic_url(@resource), notice: 'Топик создан'
    else
      new
      render :new
    end
  end

  def update
    updated = @resource.class.wo_timestamp { faye.update @resource, topic_params }

    if updated
      redirect_to UrlGenerator.instance.topic_url(@resource), notice: 'Топик изменён'
    else
      edit
      render :edit
    end
  end

  def destroy
    faye.destroy @resource
    render json: { notice: 'Топик удален' }
  end

  # html код для тултипа
  def tooltip
    topic = Topics::TopicViewFactory.new(true, true).find params[:id]

    # превью топика отображается в формате комментария
    # render(
    #   partial: 'comments/comment',
    #   layout: false,
    #   object: topic,
    #   formats: :html
    # )
    render(
      partial: 'topics/topic',
      object: topic,
      as: :topic_view,
      layout: false,
      formats: :html
    )
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

  def create_params
    topic_params.merge locale: locale_from_domain
  end

  def update_params
    topic_params
  end

  def topic_params
    allowed_params = [
      # :body,
      :title, :linked_id, :linked_type,
      # wall_ids: [],
      # video: [:id, :url, :kind, :name]
    ]

    if can?(:manage, Topic) || ['new', 'create'].include?(params[:action])
      allowed_params += [:user_id, :forum_id, :type]
    end
    allowed_params += [:broadcast] if current_user&.admin?

    params.require(:topic).permit(*allowed_params)
  end

  def compose_body
    @resource.body = Topics::ComposeBody.call(params[:topic])
  end

  def set_view
    @forums_view = Forums::View.new

    if params[:action] == 'show' && @resource
      @topic_view = Topics::TopicViewFactory.new(false, false).build @resource
    end
  end

  def set_breadcrumbs
    page_title t('page', page: @forums_view.page) if @forums_view.page > 1
    page_title i18n_t('title')
    breadcrumb t('forum'), forum_url

    if @resource && @resource.forum
      page_title @resource.forum.name
      breadcrumb @resource.forum.name, forum_topics_url(@resource.forum)

      if @forums_view.linked
        breadcrumb(
          UsersHelper.localized_name(@forums_view.linked, current_user),
          UrlGenerator.instance.forum_url(
            @forums_view.forum, @forums_view.linked
          )
        )
      end

      page_title @topic_view ? @topic_view.topic_title : @resource.title
      breadcrumb(
        @topic_view ? @topic_view.topic_title : @resource.title,
        UrlGenerator.instance.topic_url(@resource)
      ) if params[:action] == 'edit' || params[:action] == 'update'

    elsif @forums_view.forum
      page_title @forums_view.forum.name
      if params[:action] != 'index' || @forums_view.linked
        breadcrumb @forums_view.forum.name, forum_topics_url(@forums_view.forum)
      end

      if @forums_view.linked
        page_title UsersHelper.localized_name(@forums_view.linked, current_user)
      end
    end
  end

  def faye
    FayeService.new current_user, faye_token
  end
end
