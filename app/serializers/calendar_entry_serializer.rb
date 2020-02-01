class CalendarEntrySerializer < ActiveModel::Serializer
  attributes :next_episode, :next_episode_at, :duration
  has_one :anime

  def duration
    object.duration * 60 if object.duration.positive?
  end
end
