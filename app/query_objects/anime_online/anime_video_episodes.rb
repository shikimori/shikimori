class AnimeOnline::AnimeVideoEpisodes < ServiceObjectBase
  pattr_initialize :anime

  GROUP_SQL = <<-SQL.strip
    episode,
    array_agg(distinct kind) as kinds,
    array_agg(distinct substring(url from '.*://\([^/]*)')) as hostings
  SQL

  def call
    select_videos.map do |episode_video|
      AnimeOnline::AnimeVideoEpisode.new(
        episode: episode_video.episode,
        kinds: episode_video.kinds,
        hostings: episode_video.hostings
      )
    end
  end

private

  def select_videos
    @anime
      .anime_videos
      .available
      .group(:episode)
      .order(:episode)
      .select(GROUP_SQL)
  end
end
