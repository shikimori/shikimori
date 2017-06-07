class Users::Query < QueryObjectBase
  SEARCH_LIMIT = 999

  ORDER_SQL = <<-SQL
    (
      case when last_online_at > coalesce(current_sign_in_at, now()::date - 365)
        then last_online_at
        else coalesce(current_sign_in_at, now()::date - 365)
      end
    ) desc
  SQL

  def self.fetch
    new User.order(ORDER_SQL)
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
