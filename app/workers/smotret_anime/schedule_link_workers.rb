class SmotretAnime::ScheduleLinkWorkers
  include Sidekiq::Worker
  sidekiq_options queue: :default

  LINK_EXPIRE_INTERVAL = 6.months

  def perform
    Anime
      .eager_load(:smotret_anime_external_link)
      .where(
        'external_links.id is null or external_links.created_at < ?',
        LINK_EXPIRE_INTERVAL.ago
      )
      .find_each do |anime|
        SmotretAnime::LinkWorker.perform_async anime.id
      end
  end
end
