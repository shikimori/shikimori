# frozen_string_literal: true

class Collection::Update < ServiceObjectBase
  pattr_initialize :model, :params
  MAX_LINKS = 500

  def call
    Collection.transaction { update_collection }
    @model
  end

private

  def update_collection
    if @model.update update_params
      @model.links.delete_all
      CollectionLink.import collection_links
    end
  end

  def collection_links
    links.map do |link|
      CollectionLink.new link.merge(
        collection: @model,
        linked_type: @model.kind.capitalize
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
