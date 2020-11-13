class Users::CleanupDoorkeeperTokens
  include Sidekiq::Worker

  CLEANUP_INTERVAL = 4.months

  EXPIRE_GRANT_SQL = <<-SQL.squish
    revoked_at is not null and revoked_at < :now
  SQL
  EXPIRE_TOKEN_SQL = <<-SQL.squish
    (revoked_at is not null and revoked_at < :now)
    or (
      expires_in is not null
      and (created_at + expires_in * interval '1 second') < :delete_before
    )
  SQL

  def perform
    expire_grant_sql = [
      EXPIRE_GRANT_SQL,
      { now: Time.zone.now }
    ]
    expire_token_sql = [
      EXPIRE_TOKEN_SQL,
      { now: Time.zone.now, delete_before: CLEANUP_INTERVAL.ago }
    ]

    Doorkeeper::AccessGrant.where(expire_grant_sql).in_batches(&:delete_all)
    Doorkeeper::AccessToken.where(expire_token_sql).in_batches(&:delete_all)
    Doorkeeper::AccessToken.where(token: previous_refresh_tokens).in_batches(&:delete_all)
  end

private

  def previous_refresh_tokens
    Doorkeeper::AccessToken
      .where.not(previous_refresh_token: '')
      .select('previous_refresh_token')
  end
end
