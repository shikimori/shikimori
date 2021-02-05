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
      sum(case when user_rates.score = 1 then 1 else 0 end) as score_1,

      sum(case when user_rates.status = %<planned>i then 1 else 0 end)
        as status_planned,
      sum(case when user_rates.status = %<watching>i then 1 else 0 end)
        as status_watching,
      sum(case when user_rates.status = %<completed>i or
        user_rates.status = %<rewatching>i then 1 else 0 end) as status_completed,
      sum(case when user_rates.status = %<on_hold>i then 1 else 0 end)
        as status_on_hold,
      sum(case when user_rates.status = %<dropped>i then 1 else 0 end)
        as status_dropped
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
      .select(select_sql)
      .map do |entry|
        AnimeStat.new(
          entry: entry,
          scores_stats: scores_stats(entry),
          list_stats: list_stats(entry)
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

  def list_stats entry
    %i[planned completed watching dropped on_hold]
      .map do |status|
        key = :"status_#{status}"
        { key: key, value: entry.send(key) } if entry.send(key).positive?
      end
      .compact
  end

  def select_sql
    format(
      SELECT_SQL,
      table_name: @scope.table_name,
      planned: UserRate.statuses[:planned],
      watching: UserRate.statuses[:watching],
      rewatching: UserRate.statuses[:rewatching],
      completed: UserRate.statuses[:completed],
      on_hold: UserRate.statuses[:on_hold],
      dropped: UserRate.statuses[:dropped]
    )
  end
end
