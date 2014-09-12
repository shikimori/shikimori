# bug https://github.com/rails/rails/issues/12867
class PostgresFix
  include Sidekiq::Worker

  def perform
    do_hard_cleanup if need_cleanup?
  end

private
  def need_cleanup?
    ActiveRecord::Base
      .connection
      .execute(" SELECT count(*) FROM pg_stat_activity WHERE query_start < '#{2.hours.ago}' and application_name not like '%unicorn%' and application_name not like '%rails%' and application_name not like '%clockwork%' and application_name not like '%bin/sidekiq%'")
      .first['count'].to_i > 250
  end

  def do_hard_cleanup
    ActiveRecord::Base
      .connection
      .execute(" SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE query_start < '#{2.hours.ago}' and application_name not like '%unicorn%' and application_name not like '%rails%' and application_name not like '%clockwork%' and application_name not like '%bin/sidekiq%'")
  end
end
