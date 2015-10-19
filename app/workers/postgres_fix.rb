# bug https://github.com/rails/rails/issues/12867
class PostgresFix
  include Sidekiq::Worker

  def perform
    do_hard_cleanup if need_cleanup?
  end

private

  def need_cleanup?
    ActiveRecord::Base.connection
      .execute("select count(*)
        from
          pg_stat_activity
        where
          query_start < '#{1.hour.ago}'
          and application_name not like '%unicorn%'
          and application_name not like '%rails%'
          and waiting=false
          and state='idle'
          and query='COMMIT'
      ").first['count'].to_i > 250
  end

  def do_hard_cleanup
    NamedLogger.postgres_fix.info 'cleanup'

    ActiveRecord::Base.connection
      .execute("select pg_terminate_backend(pid)
        from
          pg_stat_activity
        where
          query_start < '#{1.hour.ago}'
          and application_name not like '%unicorn%'
          and application_name not like '%rails%'
          and waiting=false
          and state='idle'
          and query='COMMIT'
      ")
  end
end
