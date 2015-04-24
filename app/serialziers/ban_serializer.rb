class BanSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :comment, :moderator_id, :reason, :created_at, :duration_minutes

  def duration_minutes
    object.duration.value
  end
end
