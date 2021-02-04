class Animes::RefreshStats
  method_object :scope

  SELECT_SQL = <<~SQL.squish
    %<table_name>s.id as id,
      sum(case when user_rates.score = 10 then 1 else 0 end) as score_10,
      sum(case when user_rates.score = 9 then 1 else 0 end) as score_9,
      sum(case when user_rates.score = 8 then 1 else 0 end) as score_8,
      sum(case when user_rates.score = 7 then 1 else 0 end) as score_7,
      sum(case when user_rates.score = 6 then 1 else 0 end) as score_6,
      sum(case when user_rates.score = 5 then 1 else 0 end) as score_5,
      sum(case when user_rates.score = 4 then 1 else 0 end) as score_4,
      sum(case when user_rates.score = 3 then 1 else 0 end) as score_3,
      sum(case when user_rates.score = 2 then 1 else 0 end) as score_2,
      sum(case when user_rates.score = 1 then 1 else 0 end) as score_1
  SQL

  def call
    anime_stats = build_stats

    AnimeStat.transaction do
      AnimeStat.delete_all
      AnimeStat.import anime_stats
    end
  end

private

  def build_stats
    @scope
      .joins(:rates)
      .where.not(user_rates: { user_id: User.cheat_bot })
      .group(:id)
      .select(format(SELECT_SQL, table_name: @scope.table_name))
      .map do |entry|
        AnimeStat.new(
          entry: entry,
          scores_stats: scores_stats(entry),
          list_stats: []
        )
      end
  end

  def scores_stats entry
    10.downto(1)
      .map do |i|
        key = :"score_#{i}"
        { key: key, value: entry.send(key) } if entry.send(key).positive?
      end
      .compact
  end
end
