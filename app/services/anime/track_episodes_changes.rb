# frozen_string_literal: true

# NOTE: call in before_save callback
class Anime::TrackEpisodesChanges < ServiceObjectBase
  pattr_initialize :anime

  delegate :episodes, :episodes_aired_change, to: :anime

  def call
    return unless anime.episodes_aired_changed?

    track_anons_episodes
    track_ongoing_episodes
    track_episodes_reset
  end

private

  # change status from anons to ongoing when aired episodes appear
  def track_anons_episodes
    return unless anime.anons?
    return unless episodes_aired_change[0] == 0

    anime.status = :ongoing
  end

  # change status from ongoing to release when the last episode is aired
  def track_ongoing_episodes
    return unless anime.ongoing?
    return if episodes == 0
    return unless episodes_aired_change[1] == episodes

    anime.status = :released
    anime.released_on = Time.zone.today
  end

  # remove episodes news when aired episodes are reset
  # NOTE: status is not changed from ongoing back to anons!
  def track_episodes_reset
    return unless episodes_aired_change[1] == 0

    Topics::NewsTopic
      .where(linked: anime)
      .where(action: AnimeHistoryAction::Episode)
      .where(comments_count: 0)
      .destroy_all
  end
end
