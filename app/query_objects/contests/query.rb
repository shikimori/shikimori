class Contests::Query < QueryObjectBase
  ORDER_SQL = <<-SQL.squish
    position(
      #{Contest.table_name}.state::text in
      #{ApplicationRecord.sanitize %w[started proposing created finished].join(',')}
    ),
    case when started_on > cast(now() as date) then 2 else 1 end,
    started_on desc
  SQL

  def self.fetch
    new Contest.order(Arel.sql(ORDER_SQL))
  end

  def by_id id
    return self if id.blank?

    chain @scope.where(id:)
  end
end
