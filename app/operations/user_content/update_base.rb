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
    @model.update @params
  end

  def publish
    if @model.respond_to?(:published_at) && !@model.published_at
      @model.update! published_at: Time.zone.now
    end

    update_topic(
      forum_id: Topic::FORUM_IDS[model.class.name],
      created_at: @model.respond_to?(:published_at) ? @model.published_at : Time.zone.now,
      updated_at: @model.respond_to?(:published_at) ? @model.published_at : Time.zone.now
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

  def faye_service
    FayeService.new @model.user, nil
  end
end
