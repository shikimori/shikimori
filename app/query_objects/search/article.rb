class Search::Article < Search::SearchBase
  method_object %i[scope! phrase! locale! ids_limit!]

  def elastic_results
    search_klass.call(
      phrase: @phrase,
      locale: @locale,
      limit: @ids_limit
    )
  end
end
