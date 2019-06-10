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

    if nothig_to_rollback?
      save!
    elsif !old_released_anime?
      Anime::RollbackEpisode.call anime, episode
    else
      destroy!
    end
  end

private

  def not_tracked?
    anime.episodes_aired < episode && !anime.released?
  end

  def old_released_anime?
    anime.released? && (
      (anime.aired_on && anime.aired_on < 10.years.ago) ||
        (anime.released_on && anime.released_on < 1.week.ago)
    )
  end

  def track_episode
    EpisodeNotification::TrackEpisode.call self
  rescue MissingEpisodeError
    # task is scheduled in order to put failed task into a queue
    # so admin could investigate it later
    EpisodeNotifications::TrackEpisode.set(wait: 5.seconds).perform_async id
  end

  def nothig_to_rollback?
    subtitles? || fandub? || raw? || unknown? || torrent? || anime.episodes_aired > episode
  end
end
