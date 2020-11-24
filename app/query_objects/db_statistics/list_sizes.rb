class DbStatistics::ListSizes
  Interval = Types::Strict::Symbol
    .constructor(&:to_sym)
    .enum(:long, :short)

  INTERVALS = {
    Interval[:long] => [
      10, 20, 30, 40, 50, 60, 70, 80, 90, 100,
      120, 140, 160, 180, 200, 230, 260, 300, 350, 400, 500,
      600, 700, 800, 900, 1000
    ],
    Interval[:short] => [
      10, 20, 30, 40, 50, 60, 70, 80, 90, 100,
      120, 140, 160, 180, 200, 230, 260, 300, 350, 400
    ]
  }

  method_object :scope, :interval

  def call
    scope = @scope
      .where(status: %i[completed rewatching])
      .where.not(user_id: User.cheat_bot.select('id'))
      .group(:user_id)

    compute scope
  end

private

  def interval_values
    INTERVALS[Interval[@interval]]
  end

  def compute scope
    interval_values
      .each_with_object({})
      .with_index do |(min_value, memo), index|
        is_last = index == interval_values.size - 1

        subscope = count_scope scope, min_value, index, is_last

        count = ApplicationRecord
          .connection
          .execute("SELECT count(*) from (#{subscope.select('1').to_sql}) as t")[0]['count']

        memo[is_last ? "#{min_value}+" : min_value.to_s] = count
      end
  end

  def count_scope scope, min_value, interval_index, is_last
    if is_last
      scope.having("count(*) >= #{min_value}")
    else
      max_value = (min_value + interval_values[interval_index + 1])
      scope.having("count(*) >= #{min_value} and count(*) < #{max_value}")
    end
  end
end
