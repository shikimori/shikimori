class PgCaches::Cleanup
  include Sidekiq::Worker
  sidekiq_options unique: :until_executed

  def perform
    PgCache
      .where.not(expires_at: nil)
      .where('expires_at < ?', Time.zone.now)
      .delete_all
  end
end
