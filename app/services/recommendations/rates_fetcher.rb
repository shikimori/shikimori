# NOTE: в конфиге мемкеша должна быть опция -I 32M
# иначе кеш оценок пользователей не влезет в мемкеш!
class Recommendations::RatesFetcher
  attr_writer :user_ids
  attr_writer :target_ids
  attr_writer :by_user
  attr_writer :with_deletion
  attr_writer :user_cache_key

  MINIMUM_SCORES = 20

  USER_RATES_CONDITION = <<~SQL
    #{UserRate.table_name}.status != '#{UserRate.status_id :planned}'
    and (
      #{UserRate.table_name}.score is not null
      and #{UserRate.table_name}.score > 0
    )
  SQL
  DB_ENTRY_JOINS = <<~SQL
    inner join %<table_name>s a
      on a.id = #{UserRate.table_name}.target_id
      and a.kind != 'special'
      and a.kind != 'music'
  SQL

  def initialize klass, user_ids = nil
    @klass = klass
    @user_ids = user_ids
    @target_ids = nil
    @data = {}
    @by_user = true
    @with_deletion = true
  end

  # cached normalized scores of specific users (all by default)
  def fetch normalization
    key = "#{cache_key}_#{normalization.class.name}"

    @data[key] ||=
      Rails.cache.fetch key, expires_in: 2.weeks do
        fetch_raw_scores.each_with_object({}) do |(user_id, data), memo|
          memo[user_id] = normalization.normalize data, user_id
        end
      end
  end

private

  def fetch_raw_scores
    @fetch_raw_scores ||=
      Rails.cache.fetch cache_key, expires_in: 2.weeks do
        if @with_deletion
          fetch_rates(@klass).delete_if { |_k, v| v.size < MINIMUM_SCORES }
        else
          fetch_rates(@klass)
        end
      end
  end

  # rubocop:disable MethodLength, AbcSize
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
  # rubocop:enable MethodLength, AbcSize

  def scope klass
    scope = UserRate
      .select(:user_id, :target_id, :score)
      .where(target_type: klass.name)
      .where(USER_RATES_CONDITION)
      .joins(format(DB_ENTRY_JOINS, table_name: klass.table_name))
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
