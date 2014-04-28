class UserRateSerializer < ActiveModel::Serializer
  attributes :id, :score, :status, :episodes, :volumes, :chapters, :notice, :rewatches
  has_one :user
  has_one :target
end
