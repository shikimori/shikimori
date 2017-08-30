class ContestRoundSerializer < ActiveModel::Serializer
  attributes :id, :state
  has_many :matches
end
