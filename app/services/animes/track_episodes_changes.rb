# frozen_string_literal: true

# NOTE: call in before_save callback
class Animes::TrackEpisodesChanges
  method_object :anime

  def call
    return unless @anime.episodes_aired_changed?

    try_start_anime if @anime.anons?
    try_release_anime if @anime.ongoing?
    try_restart_anime if @anime.released?

    track_decreased_episodes
  end

private

  # change status from anons to ongoing when aired episodes appear
  def try_start_anime
    return unless @anime.episodes_aired_change[0].zero?

    @anime.status = :ongoing
  end

  # change status from ongoing to release when the last episode is aired
  def try_release_anime
    return if @anime.episodes.zero?
    return unless @anime.episodes_aired_change[1] == @anime.episodes

    last_episode_topic = Topics::NewsTopic.find_by(
      linked: @anime,
      action: AnimeHistoryAction::Episode,
      value: @anime.episodes
    )

    @anime.status = :released
    @anime.released_on = last_episode_topic ?
      last_episode_topic.created_at.to_date :
      Time.zone.today
  end

  # change status from released to ongoing
  def try_restart_anime
    return if @anime.episodes.zero?
    return unless @anime.episodes_aired < @anime.episodes

    @anime.status = :ongoing
    @anime.released_on = nil

    Topics::NewsTopic
      .where(linked: @anime)
      .where(action: AnimeHistoryAction::Released)
      .destroy_all
  end

  def track_decreased_episodes
    episode_from = @anime.episodes_aired_change[0]
    episode_to = @anime.episodes_aired_change[1]
    return if episode_from < episode_to

    Topics::NewsTopic
      .where(linked: @anime)
      .where(
        action: AnimeHistoryAction::Episode,
        value: ((episode_to + 1)..episode_from).to_a
      )
      .destroy_all

    EpisodeNotification
      .where(anime: @anime)
      .where(episode: ((episode_to + 1)..episode_from).to_a)
      .delete_all # it's important to delete, not destroy
  end
end
