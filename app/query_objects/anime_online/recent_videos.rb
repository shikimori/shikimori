class AnimeOnline::RecentVideos < SimpleQueryBase
  pattr_initialize :is_adult

  EPISODE_CONDITION = <<~SQL
    is_subtitles = true
      or is_fandub = true
      or is_raw = true
      or is_unknown = true
  SQL
  ANIME_CONDITION = <<~SQL
    (animes.status = 'ongoing' or animes.released_on > ?)
      and animes.rating != 'g' and animes.id not in (?)
  SQL

private

  def query
    EpisodeNotification
      .where(id: episode_ids)
      .order(updated_at: :desc)
  end

  def episode_ids
    EpisodeNotification
      .joins(:anime)
      .where(EPISODE_CONDITION)
      .where(ANIME_CONDITION, 1.month.ago, Anime::EXCLUDED_ONGOINGS)
      .where(adult_condition)
      .group(:anime_id)
      .select('max(episode_notifications.id) as id')
  end

  def adult_condition
    if @is_adult
      AnimeVideo::XPLAY_CONDITION
    else
      AnimeVideo::PLAY_CONDITION
    end
  end
end
