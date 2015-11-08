class HistoryWorker
  include Sidekiq::Worker
  sidekiq_options(
    unique: :until_executed,
    queue: :cpu_intensive
  )

  def perform
    AnimeHistoryService.process
  end
end
