class SmotretAnime::ScheduleLinkWorkers
  include Sidekiq::Worker
  sidekiq_options queue: :default

  def perform
    Anime
      .eager_load(:smotret_anime_external_link)
      .where('external_links.id is null')
      .find_each do |anime|
        SmotretAnime::LinkWorker.perform_async anime.id
      end
  end
end
