class VacuumDb
  include Sidekiq::Worker
  sidekiq_options queue: :cpu_intensive

  def perform
    `vacuumdb -f shikimori_production`
  end
end
