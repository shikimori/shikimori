class CollectionLinkSerializer < ActiveModel::Serializer
  attributes :id, :linked_id, :group, :text, :name, :url

  def name
    if object.linked # anime can be deleted but can still be present in collection
      scope.localized_name object.linked
    else
      '[deleted from database]'
    end
  end

  def url
    if object.linked # anime can be deleted but can still be present in collection
      scope.url_for object.linked
    end
  end
end
