class UserHistorySerializer < ActiveModel::Serializer
  attributes :id, :created_at, :description
  has_one :target

  def description
    object.format
  end
end
