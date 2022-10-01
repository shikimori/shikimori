class EpisodeNotification < ApplicationRecord
  belongs_to :anime, touch: true

  boolean_attribute :raw
  boolean_attribute :subtitles
  boolean_attribute :fandub
  boolean_attribute :anime365

  after_create :track_episode

  def rollback kind
    send "is_#{kind}=", false

    if nothig_to_rollback?
      save!
    elsif !old_released_anime?
      Anime::RollbackEpisode.call anime: anime, episode: episode
    else
      destroy!
    end
  end

private

  def old_released_anime?
    anime.released? && (
      (anime.aired_on.present? && anime.aired_on < 10.years.ago) ||
        (anime.released_on.present? && anime.released_on < 1.week.ago)
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
    subtitles? || fandub? || raw? || anime365? ||
      anime.episodes_aired > episode
  end
end
