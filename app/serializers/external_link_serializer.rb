class ExternalLinkSerializer < ActiveModel::Serializer
  attributes :id, :kind, :url, :source
end
