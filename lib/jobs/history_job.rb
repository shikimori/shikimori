class HistoryJob
  def perform
    AnimeHistoryService.process
  end
end
