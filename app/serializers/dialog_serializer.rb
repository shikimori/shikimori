class DialogSerializer < ActiveModel::Serializer
  has_one :target_user
  has_one :message
end
