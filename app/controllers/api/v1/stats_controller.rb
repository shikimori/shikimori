class Api::V1::StatsController < Api::V1Controller
  MINIMUM_COMPLETED_ANIMES = Rails.env.test? ? 1 : 30

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/stats/active_users', 'Users having at least 1 completed animes and active during last month'
  def active_users
    ids = Rails.cache.fetch(:active_users, expires_in: 5.minutes) { user_ids }
    respond_with ids
  end

private

  def user_ids
    User
      .joins(:anime_rates, :preferences)
      .where('last_online_at > ?', 1.month.ago)
      .where(user_rates: { status: 2 })
      .where(user_preferences: { list_privacy: 'public' })
      .group('users.id')
      .having('count(*) >= ?', MINIMUM_COMPLETED_ANIMES)
      .select('max(users.id) as id')
      .map(&:id)
  end
end
