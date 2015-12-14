class TopicsController < ShikimoriController
  include TopicsHelper

  load_and_authorize_resource class: Topic, only: [:new, :create, :edit, :update, :destroy]
  before_action :check_post_permission, only: [:create, :update, :destroy]
  before_action :set_view
  before_action :set_breadcrumbs

  def index
    # редирект на топик, если топик в подфоруме единственный
    if params[:linked] && @view.topics.one?
      redirect_to UrlGenerator.instance.topic_url(@view.topics.first, params[:format])
    end
  end

  def show
    @topic = Entry.with_viewed(current_user).find(params[:id])
    @topic_view = Topics::Factory.new(false, false).build @topic

    # новости аниме без комментариев поисковым системам не скармливаем
    noindex && nofollow if @topic.generated? && @topic.comments_count.zero?
    raise AgeRestricted if @topic.linked && @topic.linked.try(:censored?) && censored_forbidden?

    if ((@topic.news? || @topic.review?) && params[:linked].present?) || (
        !@topic.news? && !@topic.review? && (
          @topic.to_param != params[:id] || @topic.section.permalink != params[:section] || (@topic.linked && params[:linked] != @topic.linked.to_param && !@topic.kind_of?(ContestComment))
        )
      )
      return redirect_to UrlGenerator.instance.topic_url(@topic), status: 301
    end
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
    @resource.class.wo_timestamps do
      @resource.user_image_ids = (params[:wall] || []).uniq

      if faye.update @resource, topic_params
        redirect_to topic_url(@resource), notice: 'Топик изменён'
      else
        edit
        render :edit
      end
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
    render partial: 'topics/topic', object: topic, as: :view, layout: false, formats: :html
  end

  # выбранные топики
  def chosen
    topics = Entry
      .with_viewed(current_user)
      .where(id: params[:ids].split(',').map(&:to_i))
      .map { |topic| Topics::Factory.new(true, false).build topic }

    render partial: 'topics/topic', collection: topics, as: :view, layout: false, formats: :html
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
       [:user_id, :section_id, :text, :title, :type, :linked_id, :linked_type]
    end

    params.require(:topic).permit(*allowed_params)
  end

  def set_view
    @view = Forums::View.new
  end

  def set_breadcrumbs
    page_title i18n_t('title')
    breadcrumb t('forum'), forum_url

    if @resource && @resource.persisted?
      page_title @resource.section.name
      breadcrumb @resource.section.name, section_url(@resource.section)
    elsif @view.section
      page_title @view.section.name
      breadcrumb @view.section.name, section_url(@view.section) if params[:action] != 'index'
    end
    page_title @resource.title if @resource && @resource.persisted?
    if params[:action] == 'edit' || params[:action] == 'update'
      breadcrumb @resource.title, UrlGenerator.instance.topic_url(@resource)
    end
  end

  def faye
    FayeService.new current_user, faye_token
  end
end
