class AnimeOnline::CleanupSmotretAnime
  include Sidekiq::Worker

  URL_LIKE = "url like '%smotret-anime.ru%'"
  SELECTS = 'max(id), max(episode) as episode, anime_id'

  def perform
    smotret_videos.where(anime_id: mismatched_episode_ids).each(&:wrong!)
    smotret_videos.where(anime_id: anons_ids).each(&:wrong!)
  end

private

  def mismatched_episode_ids
    smotert_query.select { |v| v.anime.episodes < v.episode }.map(&:anime_id)
  end

  def anons_ids
    smotert_query.select { |v| v.anime.anons? }.map(&:anime_id)
  end

  def smotret_videos
    AnimeVideo.where(URL_LIKE).where(state: :working)
  end

  def smotert_query
    smotret_videos.group(:anime_id).select(SELECTS).includes(:anime)
  end
end
