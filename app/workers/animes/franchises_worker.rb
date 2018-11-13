class Animes::FranchisesWorker
  include Sidekiq::Worker
  sidekiq_options queue: :cpu_intensive

  def perform
    Animes::UpdateFranchises.call
  end
end
