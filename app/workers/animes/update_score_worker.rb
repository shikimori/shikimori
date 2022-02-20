class Animes::UpdateScoreWorker
  include Sidekiq::Worker
  sidekiq_options queue: :cpu_intensive

  def perform
    Anime::UpdateScore.call
  end
end
