class Search::Article < Search::SearchBase
  method_object %i[scope! phrase! ids_limit!]

  def elastic_results
    search_klass.call(
      phrase: @phrase,
      limit: @ids_limit
    )
  end
end
