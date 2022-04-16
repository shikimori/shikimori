# frozen_string_literal: true

class Collection::Update < UserContent::UpdateBase
  klass Collection
  MAX_LINKS = 500

  method_object :model, :params, :transition, :actor

private

  def update
    if @transition && @model.send(:"may_#{@transition}?")
      @model.send :"#{@transition}!"
      Changelog::LogUpdate.call @model, @actor
    end

    Collection.transaction { update_model } if @params
  end

  def update_model
    is_updated = @model.update update_params

    if is_updated
      Changelog::LogUpdate.call @model, @actor
      if @params[:links]
        Changelog::LogUpdate.call @model, @actor,
          changes: { links: @params[:links].map(&:to_unsafe_h) }
      end

      CollectionLink.where(collection: @model).delete_all
      CollectionLink.import collection_links
      Collection.reset_counters @model.id, :links_count
      # must touch because there can be no changes in update_params,
      # but collection_links could be changed
      @model.touch
    end

    is_updated
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
    if @model.moderation_rejected?
      Forum::OFFTOPIC_ID
    else
      super
    end
  end

  def update_params
    super.except(:links)
  end
end
