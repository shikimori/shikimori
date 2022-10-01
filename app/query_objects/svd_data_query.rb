# подготовка данных для SVD матрицы
class SvdDataQuery
  pattr_initialize :svd

  def fetch
    svd.full? ? full_data : partial_data
  end

private

  def full_data
    entry_ids = svd.klass
      .where.not(kind: [:special, :music])
      .where("aired_on_computed > '1985-01-01'")

    user_ids = UserRate
      .where(target_type: svd.klass.name, target_id: entry_ids)
      .where(Recommendations::RatesFetcher::USER_RATES_CONDITION)
      .joins(db_entry_joins_sql(svd.klass))
      .pluck(:user_id)
      .uniq

    entry_ids = UserRate
      .where(target_type: svd.klass.name, user_id: user_ids, target_id: entry_ids)
      .where(Recommendations::RatesFetcher::USER_RATES_CONDITION)
      .joins(db_entry_joins_sql(svd.klass))
      .pluck(:target_id)
      .uniq

    [user_ids, entry_ids]
  end

  def partial_data
    entry_ids = svd.klass# .where("aired_on_computed > '2011-01-01' and kind = 'tv'") # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      .where('score >= 6 and duration > 5')
      .where.not(kind: [:special, :music])
      .where(is_censored: false)
      .where.not(status: 'Not yet aired')
      .where("
        (aired_on_computed > '1995-01-01') or
        (score > 8.0) or
        ((score > 7.5) and (aired_on_computed > '1990-01-01')) or
        ((score > 7.7) and (kind = 'movie'))")
      .pluck(:id)

    user_ids = UserRate# .where("user_id < 2000") # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      .where(target_type: svd.klass.name, target_id: entry_ids)
      .where(Recommendations::RatesFetcher::USER_RATES_CONDITION)
      .joins(db_entry_joins_sql(svd.klass))
      .group(:user_id)
      .having("count(*) > 100 and count(*) < 1000")
      .pluck(:user_id)
      .uniq

    entry_ids = UserRate
      .where(target_type: svd.klass.name, user_id: user_ids, target_id: entry_ids)
      .where(Recommendations::RatesFetcher::USER_RATES_CONDITION)
      .joins(db_entry_joins_sql(svd.klass))
      .pluck(:target_id)
      .uniq

    entry_ids = UserRate
      .where(target_type: svd.klass.name, user_id: user_ids, target_id: entry_ids)
      .where(Recommendations::RatesFetcher::USER_RATES_CONDITION)
      .joins(db_entry_joins_sql(svd.klass))
      .group(:target_id)
      .having('count(*) > 4')
      .pluck(:target_id)
      .uniq

    [user_ids, entry_ids]
  end

private

  def db_entry_joins_sql klass
    format(
      Recommendations::RatesFetcher::DB_ENTRY_JOINS,
      table_name: klass.table_name
    )
  end
end
