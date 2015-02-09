class OldNewsCleaner
  include Sidekiq::Worker

  def perform
    DbEntryThread
      .where(action: AnimeHistoryAction::Episode)
      .where('created_at <= ?', 6.month.ago)
      .where.not(linked_id: Anime.ongoing.map(&:id))
      .destroy_all
  end
end
