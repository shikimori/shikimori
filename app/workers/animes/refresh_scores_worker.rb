class Animes::RefreshScoresWorker
  include Sidekiq::Worker

  def perform(entry_class, entry_id, global_average)
    entry = entry_class.find entry_id
    Anime::RefreshScores.call(entry, global_average)
  end
end
