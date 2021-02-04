class Animes::RefreshStats
  method_object :scope

  SELECT_SQL = <<~SQL.squish
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
      .group(:id)
      .select(SELECT_SQL)
      .each do |entry|
        ap entry
      end
  end
end
