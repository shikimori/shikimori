class Animes::FranchisesWorker
  include Sidekiq::Worker
  sidekiq_options(
    queue: :cpu_intensive,
    retry: false
  )

  def perform
    Animes::UpdateFranchises.call
  end
end
