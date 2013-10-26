class DanbooruTagsQuery
  include CompleteQuery
  AutocompleteLimit = 30

  def initialize(params)
    @search = SearchHelper.unescape params[:search]
    @klass = DanbooruTag
  end

private
  # ключи, по которым будет вестись поиск
  def search_fields(term)
    [:name]
  end
end
