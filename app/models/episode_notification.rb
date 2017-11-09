class EpisodeNotification < ApplicationRecord
  belongs_to :anime

  boolean_attribute :subtitles
  boolean_attribute :fandub
  boolean_attribute :raw
  boolean_attribute :unknown
  boolean_attribute :torrent

  after_create :track_episode, if: :not_tracked?

  def rollback kind
    send "is_#{kind}=", false

    if subtitles? || fandub? || raw? || unknown? || torrent?
      save!
    else
      destroy!
    end
  end

private

  def not_tracked?
    anime.episodes_aired < episode
  end

  def track_episode
    EpisodeNotification::TrackEpisode.call self

  rescue MissingEpisodeError
    # task is scheduled in order to get failed task in queue
    # which admin could investigate later
    EpisodeNotifications::TrackEpisode.set(wait: 5.seconds).perform_async id
  end
end
