class Api::V1::TopicsController < Api::V1Controller
  load_and_authorize_resource only: %i[create update destroy]

  LIMIT = 30

  UPDATE_PARAMS = %i[body title linked_id linked_type]
  CREATE_PARAMS = UPDATE_PARAMS + %i[user_id forum_id type]

  before_action only: %i[create update destroy] do
    doorkeeper_authorize! :topics if doorkeeper_token.present?
  end

  api :GET, '/topics', 'List topics'
  param :page, :pagination, required: false
  param :limit, :number, required: false, desc: "#{LIMIT} maximum"
  param :forum, %w[all] + Forum::VARIANTS, required: false
  param :linked_id, :number, required: false, desc: 'Used together with `linked_type`'
  param :linked_type, Topic::LINKED_TYPES.to_s.scan(/[A-Z]\w+/),
    required: false,
    desc: 'Used together with `linked_id`'
  # %w[Topic] + ObjectSpace.each_object(Class).select { |klass| klass <= Topic }.flat_map(&:descendants).map(&:name).uniq.sort
  param :type, %w[
    Topic
    Topics::ClubUserTopic
    Topics::EntryTopic
    Topics::EntryTopics::AnimeTopic
    Topics::EntryTopics::ArticleTopic
    Topics::EntryTopics::CharacterTopic
    Topics::EntryTopics::ClubPageTopic
    Topics::EntryTopics::ClubTopic
    Topics::EntryTopics::CollectionTopic
    Topics::EntryTopics::ContestTopic
    Topics::EntryTopics::CosplayGalleryTopic
    Topics::EntryTopics::MangaTopic
    Topics::EntryTopics::PersonTopic
    Topics::EntryTopics::RanobeTopic
    Topics::EntryTopics::CritiqueTopic
    Topics::NewsTopic
    Topics::NewsTopics::ContestStatusTopic
  ], required: false
  def index # rubocop:disable all
    @limit = [[params[:limit].to_i, 1].max, LIMIT].min

    topics_scope = Topics::Query.fetch locale_from_host, censored_forbidden?

    if params[:forum]
      forum = Forum.find_by_permalink params[:forum]
      topics_scope = topics_scope.by_forum forum, current_user, censored_forbidden?
    end

    if params[:linked_id] && params[:linked_type]
      linked = params[:linked_type].constantize.find_by(id: params[:linked_id])
      topics_scope = topics_scope.by_linked linked
    else
      topics_scope = topics_scope.where linked_id: params[:linked_id] if params[:linked_id]
      topics_scope = topics_scope.where linked_type: params[:linked_type] if params[:linked_type]
    end

    topics_scope = topics_scope.where type: params[:type] if params[:type]

    @collection = topics_scope
      .includes(:forum, :user)
      .offset(@limit * (@page - 1))
      .limit(@limit + 1)
      .as_views(true, false)

    respond_with @collection, each_serializer: TopicSerializer
  end

  api :GET, '/topics/updates', 'NewsTopics about database updates'
  param :page, :pagination, required: false
  param :limit, :number, required: false, desc: "#{LIMIT} maximum"
  def updates
    @limit = [[params[:limit].to_i, 1].max, LIMIT].min

    respond_with map_updates(updates_scope)
  end

  api :GET, '/topics/hot', 'Hot topics'
  param :limit, :number, required: false, desc: '10 maximum'
  def hot
    @limit = [[params[:limit].to_i, 1].max, 10].min

    @collection = Topics::HotTopicsQuery
      .call(limit: @limit, locale: locale_from_host)
      .map { |topic| Topics::TopicViewFactory.new(true, true).build topic }

    respond_with @collection, each_serializer: TopicSerializer
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/topics/:id', 'Show a topic'
  def show
    @topic = Topics::TopicViewFactory.new(false, false).find params[:id]
    respond_with @topic, serializer: TopicSerializer
  end

  api :POST, '/topics', 'Create a topic'
  description 'Requires `topics` oauth scope'
  param :topic, Hash do
    param :body, String, required: true
    param :forum_id, :number, required: true
    param :linked_id, :number, required: false
    param :linked_type, Topic::LINKED_TYPES, required: false
    param :title, String, required: true
    param :type, %w[Topic], required: true
    param :user_id, :number, required: true
  end
  error code: 422
  def create
    @resource = Topic::Create.call(
      faye: faye,
      params: topic_params,
      locale: locale_from_host
    )

    if @resource.persisted?
      view = Topics::TopicViewFactory.new(false, false).build(@resource)
      respond_with view, serializer: TopicSerializer
    else
      respond_with @resource
    end
  end

  api :PATCH, '/topics/:id', 'Update a topic'
  api :PUT, '/topics/:id', 'Update a topic'
  description 'Requires `topics` oauth scope'
  param :topic, Hash do
    param :body, String, required: false
    param :linked_id, :number, required: false
    param :linked_type, Topic::LINKED_TYPES, required: false
    param :title, String, required: false
  end
  def update
    is_updated = Topic::Update.call @resource, topic_params, faye

    if is_updated
      view = Topics::TopicViewFactory.new(false, false).build(@resource)
      respond_with view, serializer: TopicSerializer
    else
      respond_with @resource
    end
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :DELETE, '/topics/:id', 'Destroy a topic'
  def destroy
    Topic::Destroy.call @resource, faye

    render json: { notice: i18n_t('topic.deleted') }
  end

private

  def topic_params
    allowed_params =
      if can?(:manage, Topic) || %w[new create].include?(params[:action])
        CREATE_PARAMS
      else
        UPDATE_PARAMS
      end
    allowed_params += [:broadcast] if current_user&.admin?

    params.require(:topic).permit(*allowed_params).tap do |fixed_params|
      fixed_params[:body] = Topics::ComposeBody.call(params[:topic])
    end
  end

  def map_updates topics
    topics.map do |topic|
      {
        id: topic.id,
        linked: linked(topic),
        event: topic.action,
        episode: (topic.value.to_i if topic.value.present?),
        created_at: topic.created_at,
        url: UrlGenerator.instance.topic_url(topic)
      }
    end
  end

  def updates_scope
    Topic
      .where(
        locale: locale_from_host,
        generated: true,
        linked_type: [Anime.name, Manga.name, Ranobe.name]
      )
      .order(created_at: :desc)
      .offset(@limit * (@page - 1))
      .limit(@limit + 1)
      .order(created_at: :desc)
      .includes(:forum, :linked)
  end

  def linked topic
    if topic.linked.anime?
      AnimeSerializer.new topic.linked
    else
      MangaSerializer.new topic.linked
    end
  end

  def faye
    FayeService.new current_user, faye_token
  end
end
