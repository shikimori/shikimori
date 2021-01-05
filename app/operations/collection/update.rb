# frozen_string_literal: true

class Collection::Update < UserContent::UpdateBase
  klass Collection
  MAX_LINKS = 500

private

  def update
    if @model.update update_params
      @model.links.delete_all
      CollectionLink.import collection_links
    end
  end

  def publish
    publish_topic
    touch_all_linked
    touch_creation_date
  end

  def touch_all_linked
    @model.kind.capitalize.constantize
      .where(id: links.pluck(:linked_id))
      .update_all updated_at: Time.zone.now
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
