class Animes::FranchisesWorker
  include Sidekiq::Worker
  sidekiq_options unique: :until_executed, queue: :cpu_intensive

  def perform
    Animes::UpdateFranchises.call
  end
end
