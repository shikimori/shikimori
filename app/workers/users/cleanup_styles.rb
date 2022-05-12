class Users::CleanupStyles
  include Sidekiq::Worker

  CLEANUP_INTERVAL = 3.months

  def perform
    Style
      .where.not(compiled_css: nil)
      .where(owner: User.where('last_online_at < ?', CLEANUP_INTERVAL.ago))
      .update_all compiled_css: nil
  end
end
