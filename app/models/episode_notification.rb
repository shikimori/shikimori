class EpisodeNotification < ApplicationRecord
  belongs_to :anime, touch: true

  boolean_attribute :subtitles
  boolean_attribute :fandub
  boolean_attribute :raw
  boolean_attribute :unknown
  boolean_attribute :torrent

  after_create :track_episode, if: :not_tracked?

  def rollback kind
    send "is_#{kind}=", false

    if subtitles? || fandub? || raw? || unknown? || torrent? ||
        anime.episodes_aired > episode
      save!
    else
      Anime::RollbackEpisode.call anime, episode
    end
  end

private

  def not_tracked?
    anime.episodes_aired < episode
  end

  def track_episode
    EpisodeNotification::TrackEpisode.call self

  rescue MissingEpisodeError
    # task is scheduled in order to put failed task into a queue
    # so admin could investigate it later
    EpisodeNotifications::TrackEpisode.set(wait: 5.seconds).perform_async id
  end
end
