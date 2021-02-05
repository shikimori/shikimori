class Animes::RefreshStatsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :cpu_intensive

  Kind = Types::Strict::String
    .constructor(&:to_s)
    .enum('anime', 'manga')

  def perform kind
    Animes::RefreshStats.call Kind[kind].classify.constantize.all
  end
end
