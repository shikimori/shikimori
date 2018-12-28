class AnimeOnline::CleanupSmotretAnime
  include Sidekiq::Worker

  URL_LIKE = "url like '%smotretanime.ru%'"
  SELECTS = 'max(id), max(episode) as max_episode, anime_id'

  def perform
    smotret_videos.where(anime_id: mismatched_ongoing_ids).each(&:wrong!)
    smotret_videos.where(anime_id: mismatched_episode_ids).each(&:wrong!)
    smotret_videos.where(anime_id: anons_ids).each(&:wrong!)
  end

private

  def mismatched_ongoing_ids
    smotert_query.select { |v| v.anime.ongoing? && v.anime.episodes_aired > 0 && v.max_episode > v.anime.episodes_aired + 4 }.map(&:anime_id)
  end

  def mismatched_episode_ids
    smotert_query.select { |v| v.anime.episodes > 0 && v.anime.episodes < v.max_episode }.map(&:anime_id)
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

  def max_video_episode anime_id
    AnimeVideo.where.not(URL_LIKE).where(state: :working).where(anime_id: anime_id)
  end
end
