# TODO: выпилить ForumController
class TopicsController < ForumController
  include TopicsHelper

  load_and_authorize_resource class: Topic, only: [:new, :create, :edit, :update, :destroy]
  before_action :check_post_permission, only: [:create, :update, :destroy]
  before_action :build_forum

  caches_action :index,
    cache_path: proc { Digest::MD5.hexdigest "#{request.path}|#{params.to_json}|#{Comment.last.updated_at}|#{json?}" },
    unless: proc { user_signed_in? },
    expires_in: 2.days

  caches_action :show,
    cache_path: proc {
      topic = Entry.find params[:topic]
      Digest::MD5.hexdigest "#{request.path}|#{params.to_json}|#{topic.updated_at}|#{topic.linked ? topic.linked.updated_at : ''}|#{json?}"
    },
    unless: proc { user_signed_in? },
    expires_in: 2.days

  # главная страница сайта и форум
  def index
    @page = (params[:page] || 1).to_i

    topics = TopicsQuery
      .new(@section, current_user, @linked)
      .fetch(@page, topics_limit)
      .to_a

    @add_postloader = topics.size >= topics_limit
    @topics = topics.take(topics_limit).map {|v| TopicDecorator.new v }

    super

    # редирект на топик, если топик в подфоруме единственный
    redirect_to topic_url(@topics.first, params[:format]) and return if @linked && @topics.size == 1
  end

  # страница топика форума
  def show
    @topic = TopicDecorator.new Entry.with_viewed(current_user).find(params[:id])
    # новости аниме без комментариев поисковым системам не скармливаем
    noindex if Entry::SpecialTypes.include?(@topic.class.name) && @topic.comments_count == 0

    if ((@topic.news? || @topic.review?) && params[:linked].present?) || (
        !@topic.news? && !@topic.review? && (
          @topic.to_param != params[:id] || @topic.section.permalink != params[:section] || (@topic.linked && params[:linked] != @topic.linked.to_param && !@topic.kind_of?(ContestComment))
        )
      )
      return redirect_to topic_url(@topic), status: :moved_permanently
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
    @resource.user_image_ids = (params[:wall] || []).uniq if params[:wall].present?

    if faye.create @resource
      redirect_to topic_url(@resource), notice: 'Топик создан'
    else
      new
      render :edit
    end
  end

  # редактирование топика
  def edit
    @section = @resource.section
    super
  end

  # редактирование топика
  def update
    @resource.class.record_timestamps = false
    @resource.user_image_ids = (params[:wall] || []).uniq if params[:wall].present?

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
    topic = TopicDecorator.new Entry.find(params[:id])

    # превью топика отображается в формате комментария
    render partial: 'comments/comment', layout: false, object: topic, formats: :html
  end

  # выбранные топики
  def chosen
    topics = Entry
      .with_viewed(current_user)
      .where(id: params[:ids].split(',').map(&:to_i))
      .map {|v| TopicDecorator.new v }
      .each {|v| v.preview_mode! }

    render partial: 'topics/topic', collection: topics, layout: false, formats: :html
  end

  # подгружаемое через ajax тело топика
  def reload
    topic = TopicDecorator.new Entry.with_viewed(current_user).find(params[:id])
    if params[:is_preview] == 'true'
      topic.preview_mode!
    else
      topic.topic_mode!
    end
    render partial: 'topics/topic', object: topic
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
    @forum_view = ForumView.new

    if params[:action] != 'index'
      breadcrumb 'Форум', root_url
      breadcrumb @section.name, section_url
    end
  end

  def faye
    FayeService.new current_user, faye_token
  end
end
