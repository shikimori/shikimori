class CalendarEntrySerializer < ActiveModel::Serializer
  attributes :next_episode, :next_episode_at, :duration
  has_one :anime

  def next_episode
    object.next_episode
  end

  def next_episode_at
    object.next_episode_start_at
  end

  def duration
    object.duration * 60 if object.duration.positive?
  end

  def anime
    object.object
  end
end
