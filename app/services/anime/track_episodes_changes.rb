# frozen_string_literal: true

# NOTE: call in before_save callback
class Anime::TrackEpisodesChanges < ServiceObjectBase
  pattr_initialize :anime

  def call
    return unless @anime.episodes_aired_changed?

    track_anons_episodes
    track_ongoing_episodes
    track_released_episodes_aired
    track_episodes_decrement
  end

private

  # change status from anons to ongoing when aired episodes appear
  def track_anons_episodes
    return unless @anime.anons?
    return unless @anime.episodes_aired_change[0].zero?

    @anime.status = :ongoing
  end

  # change status from ongoing to release when the last episode is aired
  def track_ongoing_episodes
    return unless @anime.ongoing?
    return if @anime.episodes.zero?
    return unless @anime.episodes_aired_change[1] == @anime.episodes

    @anime.status = :released
    @anime.released_on = Time.zone.today
  end

  # change status from released to ongoing
  def track_released_episodes_aired
    return unless @anime.released?
    return if @anime.episodes.zero?
    return unless @anime.episodes_aired < @anime.episodes

    @anime.status = :ongoing
    @anime.released_on = nil
  end

  def track_episodes_decrement
    episode_from = @anime.episodes_aired_change[0]
    episode_to = @anime.episodes_aired_change[1]
    return if episode_from < episode_to

    Topics::NewsTopic
      .where(linked: @anime)
      .where(
        action: AnimeHistoryAction::Episode,
        value: (episode_to..(episode_from + 1)).to_a
      )
      .destroy_all
  end
end
