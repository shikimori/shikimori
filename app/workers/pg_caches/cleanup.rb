class PgCaches::Cleanup
  include Sidekiq::Worker

  def perform
    PgCacheData
      .where.not(expires_at: nil)
      .where('expires_at < ?', Time.zone.now)
      .delete_all
  end
end
