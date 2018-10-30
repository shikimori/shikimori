class SimilarUsersService
  prepend ActiveCacher.instance

  MAXIMUM_RESULTS = 510

  instance_cache :users, :compatibility_service, :rates_fetcher, :similarities

  def initialize user, klass, threshold
    @user = user
    @klass = klass
    @threshold = threshold
  end

  def fetch
    similarities
      .select { |_, v| v.present? }
      .sort_by { |_, v| -v }
      .take(MAXIMUM_RESULTS)
      .map(&:first)
  end

private

  def similarities
    users.each_with_object({}) do |user, memo|
      memo[user.id] = compatibility_service.fetch user, rates_fetcher
    end
  end

  def rates_fetcher
    Recommendations::RatesFetcher.new(@klass)
  end

  def compatibility_service
    CompatibilityService.new @user, @user, @klass
  end

  def users
    table_name = "#{@klass.name.downcase}_rates".to_sym

    User
      .joins(table_name)
      .where(user_rates: { status: UserRate.statuses[:completed] })
      .where('user_rates.score > 0')
      .where.not(id: @user.id)
      .group('users.id')
      .having("count(*) > #{@threshold}")
  end
end
