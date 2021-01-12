class UserContent::UpdateBase < ServiceObjectBase
  extend DslAttribute
  dsl_attribute :klass

  pattr_initialize :model, :params

  def call
    klass.transaction do
      update
      publish if @model.published? && hidden_topic?
      unpublish unless @model.published? || hidden_topic?
    end

    @model
  end

private

  def update
    @model.update update_params
  end

  def update_params
    @params.merge changed_at: Time.zone.now
  end

  def publish
    if @model.respond_to?(:published_at) && !@model.published_at
      @model.update!(
        published_at: Time.zone.now,
        changed_at: Time.zone.now
      )
    end
    published_at = @model.respond_to?(:published_at) ? @model.published_at : Time.zone.now

    update_topic(
      forum_id: publish_forum_id,
      created_at: published_at,
      updated_at: published_at
    )
    touch_creation_date
  end

  def unpublish
    update_topic forum_id: Forum::HIDDEN_ID
  end

  def update_topic params
    @model.topics.each do |topic|
      Topic::Update.call(
        topic: topic,
        params: params,
        faye: faye_service
      )
    end
  end

  def touch_creation_date
    @model.update created_at: Time.zone.now, updated_at: Time.zone.now
  end

  def hidden_topic?
    @model.topics.first.forum_id == Forum::HIDDEN_ID
  end

  def publish_forum_id
    Topic::FORUM_IDS[model.class.name]
  end

  def faye_service
    FayeService.new @model.user, nil
  end
end
