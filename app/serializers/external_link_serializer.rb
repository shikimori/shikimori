class ExternalLinkSerializer < ActiveModel::Serializer
  attributes :id, :kind, :url, :source, :entry_id, :entry_type,
    :created_at, :updated_at, :imported_at
end
