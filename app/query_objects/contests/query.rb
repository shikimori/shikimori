class Contests::Query < QueryObjectBase
  ORDER_SQL = <<-SQL.squish
    position(
      #{Contest.table_name}.state::text in
      #{Contest.sanitize %w[started proposing created finished].join(',')}
    ), started_on desc
  SQL

  def self.fetch
    new Contest.order(ORDER_SQL)
  end
end
