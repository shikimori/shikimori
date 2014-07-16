class PostgresFix
  include Sidekiq::Worker

  def perform
    ActiveRecord::Base.connection.execute(" SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE query_start < '#{2.hours.ago}'")
  end
end
