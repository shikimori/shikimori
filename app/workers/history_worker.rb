class HistoryWorker
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform
    AnimeHistoryService.process
  end
end
