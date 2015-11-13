class VacuumDb
  include Sidekiq::Worker
  sidekiq_options(
    unique: :until_executed,
    queue: :cpu_intensive
  )

  def perform
    %x{vacuumdb -f shikimori_production}
  end
end
