class TopicsController < ShikimoriController
  load_and_authorize_resource class: Entry, only: [:new, :create, :edit, :update, :destroy]
  before_action :check_post_permission, only: [:create, :update, :destroy]
  before_action :set_view
  before_action :set_breadcrumbs

  def index
    # редирект на топик, если топик в подфоруме единственный
    if params[:linked_id] && @view.topics.one?
      return redirect_to UrlGenerator.instance.topic_url(
        @view.topics.first.topic, params[:format]), status: 301
    end

    # редирект, исправляющий linked
    if params[:linked_id] && @view.linked.to_param != params[:linked_id]
      return redirect_to UrlGenerator.instance.forum_url(
        @view.forum, @view.linked), status: 301
    end
  end

  def show
    expected_url = UrlGenerator.instance.topic_url @resource
    if request.url.gsub(/\?.*/, '') != expected_url && request.format != 'rss'
      return redirect_to expected_url, status: 301
    end

    # новости аниме без комментариев поисковым системам не скармливаем
    noindex && nofollow if @resource.generated? && @resource.comments_count.zero?
    raise AgeRestricted if @resource.linked && @resource.linked.try(:censored?) && censored_forbidden?
  end

  # создание нового топика
  def new
    noindex
    page_title i18n_t("new_#{@resource.news? ? :news : :topic}")
    @back_url = @breadcrumbs[@breadcrumbs.keys.last]
  end

  # создание топика
  def create
    if faye.create @resource
      redirect_to UrlGenerator.instance.topic_url(@resource), notice: 'Топик создан'
    else
      new
      render :new
    end
  end

  # редактирование топика
  def edit
  end

  # редактирование топика
  def update
    updated = @resource.class.wo_timestamp { faye.update @resource, topic_params }

    if updated
      redirect_to UrlGenerator.instance.topic_url(@resource), notice: 'Топик изменён'
    else
      edit
      render :edit
    end
  end

  # удаление топика
  def destroy
    faye.destroy @resource
    render json: { notice: 'Топик удален' }
  end

  # html код для тултипа
  def tooltip
    topic = Topics::Factory.new(true, true).find params[:id]

    # превью топика отображается в формате комментария
    # render partial: 'comments/comment', layout: false, object: topic, formats: :html
    render(
      partial: 'topics/topic',
      object: topic,
      as: :view,
      layout: false,
      formats: :html
    )
  end

  # выбранные топики
  def chosen
    topics = Entry
      .with_viewed(current_user)
      .where(id: params[:ids].split(',').map(&:to_i))
      .map { |topic| Topics::Factory.new(true, false).build topic }

    render(
      partial: 'topics/topic',
      collection: topics,
      as: :view,
      layout: false,
      formats: :html
    )
  end

  # подгружаемое через ajax тело топика
  def reload
    topic = Entry.with_viewed(current_user).find params[:id]
    view = Topics::Factory.new(params[:is_preview] == 'true', false).build topic

    # render 'topics/topic', view: view
    render partial: 'topics/topic', object: view, as: :view
  end

private

  def topic_params
    allowed_params = [:body, :title, :linked_id, :linked_type, wall_ids: []]
    allowed_params += [:user_id, :forum_id, :type] if can?(:manage, Topic) || ['new','create'].include?(params[:action])
    allowed_params += [:broadcast] if user_signed_in? && current_user.admin?

    params.require(:topic).permit *allowed_params
  end

  def set_view
    @view = Forums::View.new

    if params[:action] == 'show'
      @resource = Entry.with_viewed(current_user).find(params[:id])
      @topic_view = Topics::Factory.new(false, false).build @resource if @resource
    end
  end

  def set_breadcrumbs
    page_title i18n_t('title')
    breadcrumb t('forum'), forum_url

    if @resource && @resource.forum
      page_title @resource.forum.name
      breadcrumb @resource.forum.name, forum_topics_url(@resource.forum)

      if @view.linked
        breadcrumb(
          UsersHelper.localized_name(@view.linked, current_user),
          UrlGenerator.instance.forum_url(@view.forum, @view.linked)
        )
      end

      page_title @topic_view ? @topic_view.topic_title : @resource.title
      breadcrumb(
        @topic_view ? @topic_view.topic_title : @resource.title,
        UrlGenerator.instance.topic_url(@resource)
      ) if params[:action] == 'edit' || params[:action] == 'update'

    elsif @view.forum
      page_title @view.forum.name
      if params[:action] != 'index' || @view.linked
        breadcrumb @view.forum.name, forum_topics_url(@view.forum)
      end

      if @view.linked
        page_title UsersHelper.localized_name(@view.linked, current_user)
      end
    end
  end

  def faye
    FayeService.new current_user, faye_token
  end
end
