class PostgresFix
  include Sidekiq::Worker

  def perform
    ActiveRecord::Base.connection.execute(" SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE query_start < '#{2.hours.ago}' and application_name not like '%unicorn%' and application_name not like '%rails%' and application_name not like '%clockwork%' and application_name not like '%bin/sidekiq%'")
  end
end
