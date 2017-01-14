class BanSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :comment, :moderator_id, :reason, :created_at,
    :duration_minutes

  has_one :user
  has_one :moderator

  def duration_minutes
    object.duration.value
  end
end
