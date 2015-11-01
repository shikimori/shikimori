# TODO: выпилить ForumController
class TopicsController < ForumController
  include TopicsHelper

  load_and_authorize_resource class: Topic, only: [:new, :create, :edit, :update, :destroy]
  before_action :check_post_permission, only: [:create, :update, :destroy]
  before_action :build_forum
  before_action :set_breadcrumbs, only: [:show, :edit, :new]

  #caches_action :index,
    #cache_path: proc { Digest::MD5.hexdigest "#{request.path}|#{params.to_json}|#{Comment.last.updated_at}|#{json?}" },
    #unless: proc { user_signed_in? },
    #expires_in: 2.days

  #caches_action :show,
    #cache_path: proc {
      #topic = Entry.find params[:id]
      #Digest::MD5.hexdigest "#{request.path}|#{params.to_json}|#{topic.updated_at}|#{topic.linked ? topic.linked.updated_at : ''}|#{json?}"
    #},
    #unless: proc { user_signed_in? },
    #expires_in: 2.days

  # главная страница сайта и форум
  def index
    @page = (params[:page] || 1).to_i
    @limit = topics_limit

    topics, @add_postloader = TopicsQuery.new(current_user)
      .by_section(@section)
      .by_linked(@linked)
      .postload(@page, @limit)
      .result

    @collection = topics.map do |topic|
      Topics::Factory.new(true, @section.permalink == 'reviews').build topic
    end

    super

    # редирект на топик, если топик в подфоруме единственный
    redirect_to topic_url(topics.first, params[:format]) and return if @linked && @collection.one?
  end

  # страница топика форума
  def show
    @topic = Entry.with_viewed(current_user).find(params[:id])
    @view = Topics::Factory.new(false, false).build @topic

    # новости аниме без комментариев поисковым системам не скармливаем
    noindex && nofollow if @topic.generated? && @topic.comments_count.zero?
    raise AgeRestricted if @topic.linked && @topic.linked.try(:censored?) && censored_forbidden?

    if ((@topic.news? || @topic.review?) && params[:linked].present?) || (
        !@topic.news? && !@topic.review? && (
          @topic.to_param != params[:id] || @topic.section.permalink != params[:section] || (@topic.linked && params[:linked] != @topic.linked.to_param && !@topic.kind_of?(ContestComment))
        )
      )
      return redirect_to topic_url(@topic), status: 301
    end

    super
  end

  # создание нового топика
  def new
    noindex
    super
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
    super
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
    topic = Topics::Factory.new(true, false).find params[:id]

    # превью топика отображается в формате комментария
    render partial: 'comments/comment', layout: false, object: topic, formats: :html
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

  # количество отображаемых топиков
  def topics_limit
    params[:format] == 'rss' ? 30 : 8
  end

  def build_forum
    @forum_view = ForumView.new @resource
  end

  def set_breadcrumbs
    breadcrumb 'Форум', root_url
    breadcrumb @forum_view.section.name, section_url(@forum_view.section)
    breadcrumb @resource.title, UrlGenerator.instance.topic_url(@resource) if params[:action] == 'edit'
  end

  def faye
    FayeService.new current_user, faye_token
  end
end
