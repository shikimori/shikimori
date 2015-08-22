class HistoryWorker
  include Sidekiq::Worker
  sidekiq_options(
    unique: true,
    queue: :cpu_intensive
  )

  def perform
    AnimeHistoryService.process
  end
end
