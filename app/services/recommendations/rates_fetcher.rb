class Recommendations::RatesFetcher
  attr_writer :user_ids, :target_ids, :by_user, :with_deletion, :user_cache_key

  MINIMUM_SCORES = 100

  USER_RATES_SQL = <<~SQL.squish
    user_rates.status != '#{UserRate.status_id :planned}'
      and user_rates.score > 0
  SQL

  # greately reduce number of selected UserRates by filtering them by users list size
  LIST_SIZE_SQL = <<-SQL.squish
    user_rates.user_id in (
      select users.id
        from users
        inner join user_rates
          on user_rates.user_id = users.id and #{USER_RATES_SQL}
        group by users.id
        having count(*) >= %<minimum_scores>i
    )
  SQL

  DB_ENTRY_JOINS_SQL = <<~SQL.squish
    inner join %<table_name>s a
      on a.id = user_rates.target_id
      and a.kind != 'special'
      and a.kind != 'music'
  SQL

  def initialize klass, user_ids = nil
    @klass = klass
    @user_ids = user_ids
    @target_ids = nil
    @data = {}
    @fetch_raw_scores = {}
    @by_user = true
    @with_deletion = true
  end

  # cached normalized scores of specific users (all by default)
  def fetch normalization
    key = "#{cache_key}_#{normalization.class.name}"

    @data[key] ||=
      PgCache.fetch key, expires_in: 8.weeks, serializer: MessagePack do
        fetch_raw_scores.each_with_object({}) do |(user_id, data), memo|
          memo[user_id] = normalization.normalize data, user_id
        end
      end
  end

private

  def fetch_raw_scores
    @fetch_raw_scores[cache_key] ||=
      PgCache.fetch cache_key, expires_in: 8.weeks, serializer: MessagePack do
        fetch_rates @klass
      end
  end

  def fetch_rates klass
    data = {}

    UserRate.fetch_raw_data(scope(klass).to_sql, 500_000) do |rate|
      if @by_user
        data[rate['user_id']] ||= {}
        data[rate['user_id']][rate['target_id']] = rate['score']
      else
        data[rate['target_id']] ||= {}
        data[rate['target_id']][rate['user_id']] = rate['score']
      end
    end

    data
  end

  def scope klass
    # no need in filtering by list size if @user_ids is provided
    is_list_size_sql = @with_deletion && @user_ids.blank?

    scope = UserRate
      .select(:user_id, :target_id, :score)
      .where(target_type: klass.name)
      .where(USER_RATES_SQL)
      .where((
        format(LIST_SIZE_SQL, minimum_scores: MINIMUM_SCORES) if is_list_size_sql
      ))
      .joins(format(DB_ENTRY_JOINS_SQL, table_name: klass.table_name))
      .order(:id)

    scope.where! user_id: @user_ids if @user_ids.present?
    scope.where! target_id: @target_ids if @target_ids.present?
    scope
  end

  def cache_key
    [
      :raw_user_rates,
      @klass.name,
      MINIMUM_SCORES,
      @by_user,
      @with_deletion,
      @user_ids,
      @user_cache_key,
      @target_ids
    ].join '_'
  end
end
