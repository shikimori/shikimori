# frozen_string_literal: true

class Collection::Update < ServiceObjectBase
  pattr_initialize :model, :params
  MAX_LINKS = 500

  def call
    Collection.transaction do
      update_collection
      publish if @model.published? && @model.topics.none?
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
    generate_topic
    touch_all_linked
    change_creation_date
  end

  def generate_topic
    @model.generate_topics @model.locale
  end

  def touch_all_linked
    @model.kind.capitalize.constantize
      .where(id: links.pluck(:linked_id))
      .update_all updated_at: Time.zone.now
  end

  def change_creation_date
    @model.update created_at: Time.zone.now
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
end
