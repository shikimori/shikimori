class TopicsController < ShikimoriController
  include TopicsHelper

  load_and_authorize_resource class: Topic, only: [:new, :create, :edit, :update, :destroy]
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
    if request.url != expected_url
      return redirect_to expected_url, status: 301
    end

    # новости аниме без комментариев поисковым системам не скармливаем
    noindex && nofollow if @resource.generated? && @resource.comments_count.zero?
    raise AgeRestricted if @resource.linked && @resource.linked.try(:censored?) && censored_forbidden?

    # if ((@resource.news? || @resource.review?) && params[:linked_id].present?) || (
        # !@resource.news? && !@resource.review? && (
          # @resource.to_param != params[:id] ||
          # @resource.forum.permalink != params[:forum] ||
          # (@resource.linked && params[:linked_id] != @resource.linked.to_param &&
            # !@resource.kind_of?(ContestComment))
        # )
      # )
      # return redirect_to UrlGenerator.instance.topic_url(@resource), status: 301
    # end
  end

  # создание нового топика
  def new
    noindex
    page_title i18n_t('new_topic')
  end

  # создание топика
  def create
    @resource.user_image_ids = (params[:wall] || []).uniq

    if faye.create @resource
      redirect_to topic_url(@resource), notice: 'Топик создан'
    else
      new
      render :edit
    end
  end

  # редактирование топика
  def edit
  end

  # редактирование топика
  def update
    @resource.class.record_timestamps = false
    @resource.user_image_ids = (params[:wall] || []).uniq

    if faye.update @resource, topic_params
      redirect_to topic_url(@resource), notice: 'Топик изменён'
    else
      edit
      render :edit
    end
    @topic.class.record_timestamps = true
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
    allowed_params = if params[:action] == 'update' && !can?(:manage, Topic)
       [:text, :title, :linked_id, :linked_type]
    else
       [:user_id, :forum_id, :text, :title, :type, :linked_id, :linked_type]
    end

    params.require(:topic).permit(*allowed_params)
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
