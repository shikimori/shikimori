class CollectionSerializer < ActiveModel::Serializer
  attributes :id, :kind, :name, :text, :state
  has_one :user
  has_many :links
end
