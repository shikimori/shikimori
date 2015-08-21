class UsersQuery
  include CompleteQuery
  AUTOCOMPLETE_LIMIT = 10

  def initialize params
    @params = params

    @search = SearchHelper.unescape params[:search]
    @klass = User
  end

  def bans_count
    query = User.find(@params[:user_id])
      .bans
      .where('created_at > ?', DateTime.now - Ban::ACTIVE_DURATION)
      .where.not(moderator_id: User::Banhammer_ID)

    warnings = query.where(duration: 0).count
    bans = query.where.not(duration: 0).count

    (warnings > 0 ? 1 : 0) + bans
  end

  # для поиска на странице поиска пользователей (тут специально нет reverse, т.к. на выходе нужен relation)
  def search
    search_order @klass.where(search_queries.join(' or '))
  end

private

  # ключи, по которым будет вестись поиск
  def search_fields term
    [:nickname]
  end
end
