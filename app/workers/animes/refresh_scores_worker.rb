class Animes::RefreshScoresWorker
  include Sidekiq::Worker

  def perform(entry_class, entry_id, global_average)
    Anime::RefreshScores.call(entry_class, entry_id, global_average)
  end
end
