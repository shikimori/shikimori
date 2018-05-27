class KillFreezedPostgresQueries
  include Sidekiq::Worker

  KILL_FREEZED_QUERIES_SQL = <<~SQL
    select
      pg_terminate_backend(pid),
      now(),
      now()-xact_start as duration,
      * from pg_stat_activity
    where
      (now() - pg_stat_activity.xact_start) > '2 hour'::interval
      and usename not in ('postgres', 'backuper')
      and state<>'idle'
  SQL

  def perform
    ApplicationRecord.connection.execute(KILL_FREEZED_QUERIES_SQL)
  end
end
