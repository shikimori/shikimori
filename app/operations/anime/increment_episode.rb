class Anime::IncrementEpisode
  method_object %i[anime! aired_at! user!]

  def call
    return if @anime.released?

    episodes_before = @anime.episodes_aired
    track_episode episodes_before + 1

    if episodes_before != @anime.episodes_aired
      create_version episodes_before
    end
  end

private

  def track_episode episode
    EpisodeNotification::Track.call(
      anime: @anime,
      episode: episode,
      aired_at: @aired_at,
      is_raw: true
    )
  end

  def create_version episodes_before
    Version.create!(
      user: @user,
      item: @anime,
      state: 'auto_accepted',
      item_diff: {
        'episodes_aired' => [episodes_before, @anime.episodes_aired]
      }
    )
  end
end
