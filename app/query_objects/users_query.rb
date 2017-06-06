class UsersQuery
  include CompleteQuery
  AUTOCOMPLETE_LIMIT = 10

  def initialize params
    @params = params

    @search = SearchHelper.unescape params[:search]
    @klass = User
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
