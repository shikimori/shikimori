class Api::V1::StatsController < Api::V1::ApiController
  respond_to :json

  MINIMUM_COMPLETED_ANIMES = Rails.env.test? ? 1 : 30

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, '/stats/active_users', 'Users having at least 1 completed animes and active during last month'
  def active_users
    ids = User
      .joins(:anime_rates, :preferences)
      .where('last_online_at > ?', 1.month.ago)
      .where(user_rates: { status: 2 })
      .where(user_preferences: { list_privacy: 'public' })
      .group('users.id')
      .having('count(*) >= ?', MINIMUM_COMPLETED_ANIMES)
      .select('max(users.id) as id')
      .map(&:id)

    respond_with ids
  end
end
