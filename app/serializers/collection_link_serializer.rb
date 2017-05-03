class CollectionLinkSerializer < ActiveModel::Serializer
  attributes :collection_id, :linked_id, :linked_type, :group, :text
end
