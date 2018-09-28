class UserRates::LogsCleaner
  include Sidekiq::Worker
  sidekiq_options(
    unique: :until_executed,
    queue: :cpu_intensive
  )

  LOGS_LIVE_INTERVAL = 1.month

  def perform
    UserRatesLog.where('created_at < ?', LOGS_LIVE_INTERVAL.ago).delete_all
  end
end
