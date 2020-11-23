class AchievementsController < ShikimoriController
  before_action do
    og page_title: i18n_i('Achievement', :other)
  end
  before_action :find_collection, only: %i[group]
  before_action :set_collection, only: %i[show users]

  helper_method :users_scope

  USERS_PER_PAGE = 48
  MAX_PAGE = 50

  def index
    @collection = NekoRepository.instance
  end

  def group
    og page_title: @collection.first.group_name
    breadcrumb i18n_i('Achievement', :other), achievements_url
  end

  def show
    @topic_resource = build_topic_resource @collection.first.topic_id

    og page_title: @collection.first.group_name
    og page_title: @collection.first.neko_name

    breadcrumb i18n_i('Achievement', :other), achievements_url
    breadcrumb(
      @collection.first.group_name,
      group_achievements_url(@collection.first.group)
    )
  end

  def users # rubocop:disable AbcSize
    show
    @resource = @collection.find { |achievement| achievement.level == params[:level].to_i }

    og page_title: i18n_t('level', level: @resource.level)
    breadcrumb(
      @resource.title(current_user, ru_host?),
      achievement_url(@resource.group, @resource.neko_id)
    )

    ensure_redirect! achievement_users_url(
      @resource.group,
      @resource.neko_id,
      @resource.level
    )

    @scope = users_scope.filter(neko_id: @resource.neko_id, level: @resource.level)
    @users = @scope.paginate(@page, USERS_PER_PAGE)
  end

private

  def find_collection # rubocop:disable AbcSize
    @collection = NekoRepository.instance.select do |achievement|
      achievement.group == params[:group].to_sym
    end

    if @collection.empty?
      id_collection = NekoRepository.instance.select do |achievement|
        achievement.neko_id == params[:group].to_sym
      end
      raise ActiveRecord::RecordNotFound if id_collection.none?

      ensure_redirect! achievement_url(
        id_collection.first.group,
        id_collection.first.neko_id
      )
    end
  end

  def set_collection
    @collection = NekoRepository
      .instance
      .select { |v| v.neko_id == params[:id].to_sym && v.group == params[:group].to_sym }
      .map do |v|
        current_user&.achievements&.find { |a| a.neko_id == v.neko_id && a.level == v.level } || v
      end

    raise ActiveRecord::RecordNotFound if @collection.none?
  end

  def build_topic_resource topic_id
    return unless ru_host?
    return unless topic_id

    topic = Topic.find_by id: topic_id

    if topic
      OpenStruct.new(
        preview_topic_view: Topics::TopicViewFactory.new(true, false).build(
          topic
        )
      )
    end
  end

  def users_scope
    Achievements::UsersQuery.fetch((current_user if params[:action] == 'users'))
  end
end
