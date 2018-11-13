class UserRates::LogsCleaner
  include Sidekiq::Worker
  sidekiq_options queue: :cpu_intensive

  LOGS_LIVE_INTERVAL = 2.weeks

  def perform
    UserRateLog.where('created_at < ?', LOGS_LIVE_INTERVAL.ago).delete_all
  end
end
