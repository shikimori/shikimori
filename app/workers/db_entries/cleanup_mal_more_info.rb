class DbEntries::CleanupMalMoreInfo
  include Sidekiq::Worker

  def perform
    [Anime, Manga].each do |klass|
      klass
        .where("more_info ilike '% [MAL]'")
        .update_all more_info: nil
    end
  end
end
