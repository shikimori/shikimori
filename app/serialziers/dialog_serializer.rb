class DialogSerializer < ActiveModel::Serializer
  has_one :user
  has_one :message
end
