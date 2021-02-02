# frozen_string_literal: true

class Collection::Update < UserContent::UpdateBase
  klass Collection
  MAX_LINKS = 500

  pattr_initialize :model, %i[params transition]

private

  def update
    if @transition && @model.send(:"can_#{@transition}?")
      @model.send :"#{@transition}!"
    end

    if @params && @model.update(update_params)
      CollectionLink.where(collection: @model).delete_all
      CollectionLink.import collection_links
      # must touch because there can be no changes in update_params,
      # but collection_links could be changed
      @model.touch
    end
  end

  def publish
    super
    touch_all_linked
  end

  def touch_all_linked
    @model.kind.capitalize.constantize
      .where(id: @model.links.pluck(:linked_id))
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

  def publish_forum_id
    if @model.rejected?
      Forum::OFFTOPIC_ID
    else
      super
    end
  end

  def update_params
    super.except(:links).merge(links_count: links.size)
  end
end
