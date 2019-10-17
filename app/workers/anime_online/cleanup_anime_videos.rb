class AnimeOnline::CleanupAnimeVideos
  include Sidekiq::Worker
  CLEANUP_INTERVAL = 6.months

  def perform
    AnimeVideo
      .where(state: %i[rejected broken wrong banned_hosting copyrighted])
      .where('updated_at < ?', CLEANUP_INTERVAL.ago)
      .find_each(&:destroy)
  end
end
