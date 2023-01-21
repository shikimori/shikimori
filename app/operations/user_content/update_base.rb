class UserContent::UpdateBase
  extend DslAttribute
  dsl_attribute :klass
  dsl_attribute :is_publishable

  method_object :model, :params, :actor

  def call
    is_updated = nil

    klass.transaction do
      is_updated = update

      if is_publishable
        publish if @model.published? && hidden_topic?
        unpublish unless @model.published? || hidden_topic?
      end
    end

    is_updated
  end

private

  def update
    is_updated = @model.update update_params
    Changelog::LogUpdate.call @model, @actor if is_updated
    is_updated
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
    Topic::Update.call @model.topic, params, faye_service
  end

  def touch_creation_date
    @model.update created_at: Time.zone.now, updated_at: Time.zone.now
  end

  def hidden_topic?
    @model.topic.forum_id == Forum::HIDDEN_ID
  end

  def publish_forum_id
    Topic::FORUM_IDS[model.class.name]
  end

  def faye_service
    FayeService.new @model.user, nil
  end
end
