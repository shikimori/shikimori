# frozen_string_literal: true

class Collection::Update < ServiceObjectBase
  pattr_initialize :model, :params

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
    @params[:linked_ids].each_with_index.map do |linked_id, index|
      CollectionLink.new(
        collection: @model,
        linked_id: linked_id,
        linked_type: @model.kind.capitalize,
        group: @params[:linked_groups][index]
      )
    end
  end

  def update_params
    params.except(:linked_ids, :linked_groups)
  end
end
