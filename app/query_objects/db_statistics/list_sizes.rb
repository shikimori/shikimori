class DbStatistics::ListSizes
  INTERVALS = [
    10,
    20,
    30,
    40,
    50,
    60,
    70,
    80,
    90,
    100,
    120,
    140,
    160,
    180,
    200,
    230,
    260,
    300,
    350,
    400,
    500,
    600,
    700,
    800,
    900,
    1000
  ]

  method_object :scope

  def call
    scope = @scope
      .where(status: %i[completed rewatching])
      .where.not(user_id: User.cheat_bot.select('id'))
      .group(:user_id)

    compute scope
  end

private

  def compute scope
    INTERVALS.each_with_object({}).with_index do |(min_value, memo), index|
      is_last = index == INTERVALS.size - 1

      count_scope =
        if is_last
          scope.having("count(*) >= #{min_value}")
        else
          max_value = (min_value + INTERVALS[index + 1])
          scope.having("count(*) >= #{min_value} and count(*) < #{max_value}")
        end

      count = ApplicationRecord
        .connection
        .execute("SELECT count(*) from (#{count_scope.select('1').to_sql}) as t")[0]['count']

      memo[is_last ? "#{min_value}+" : min_value.to_s] = count
    end
  end
end
