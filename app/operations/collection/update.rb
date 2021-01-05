# frozen_string_literal: true

class Collection::Update < ServiceObjectBase
  pattr_initialize :model, :params
  MAX_LINKS = 500

  def call
    Collection.transaction do
      update_collection
      publish if @model.published? && hidden_topic?
    end
    @model
  end

private

  def update_collection
    if @model.update update_params
      @model.links.delete_all
      CollectionLink.import collection_links
      @model.touch
    end
  end

  def publish
    publish_topic
    touch_all_linked
    touch_creation_date
  end

  def publish_topic
    @model.topics.each do |topic|
      Topic::Update.call(
        topic: topic,
        params: {
          forum_id: Topic::FORUM_IDS[model.class.name],
          created_at: Time.zone.now,
          updated_at: Time.zone.now
        },
        faye: faye_service
      )
    end
  end

  def touch_all_linked
    @model.kind.capitalize.constantize
      .where(id: links.pluck(:linked_id))
      .update_all updated_at: Time.zone.now
  end

  def touch_creation_date
    @model.update created_at: Time.zone.now, updated_at: Time.zone.now
  end

  def collection_links
    links.map do |link|
      CollectionLink.new link.merge(
        collection: @model,
        linked_type: @model.db_type
      )
    end
  end

  def links
    (@params[:links] || []).take(MAX_LINKS)
  end

  def update_params
    params.except(:links)
  end

  def faye_service
    FayeService.new @model.user, nil
  end

  def hidden_topic?
    @model.topics.first.forum_id == Forum::HIDDEN_ID
  end
end
