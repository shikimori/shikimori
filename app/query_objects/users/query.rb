class Users::Query < QueryObjectBase
  SEARCH_LIMIT = 999

  ORDER_SQL = <<-SQL
    greatest(
      last_online_at,
      coalesce(current_sign_in_at, now()::date - 365)
    ) desc, id desc
  SQL

  def self.fetch
    new User.order(Arel.sql(ORDER_SQL))
  end

  def search phrase
    return self if phrase.blank?

    chain Search::User.call(
      scope: @scope,
      phrase: phrase,
      ids_limit: SEARCH_LIMIT
    )
  end
end
