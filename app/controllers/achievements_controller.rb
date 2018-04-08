class AchievementsController < ShikimoriController
  before_action do
    og page_title: i18n_i('Achievement', :other)
  end

  def index
    @collection = NekoRepository.instance
  end

  def group # rubocop:disable AbcSize
    @collection = NekoRepository.instance
      .select { |v| v.group == params[:group].to_sym }

    raise ActiveRecord::RecordNotFound if @collection.empty?
    og page_title: @collection.first.group_name
    breadcrumb i18n_i('Achievement', :other), achievements_url
  end

  def show # rubocop:disable AbcSize, MethodLength
    @collection = NekoRepository.instance
      .select { |v| v[:neko_id] == params[:id].to_sym }

    raise ActiveRecord::RecordNotFound if @collection.empty?

    @topic_resource = build_topic_resource @collection.first.topic_id

    og page_title: @collection.first.group_name
    og page_title: @collection.first.neko_name

    breadcrumb i18n_i('Achievement', :other), achievements_url
    breadcrumb(
      @collection.first.group_name,
      group_achievements_url(@collection.first.group)
    )
  end

private

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
end
