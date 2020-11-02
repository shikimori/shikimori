class Search::Licensor < Search::SearchBase
  method_object %i[phrase! kind! ids_limit!]

  def call
    elastic_results
  end

  def elastic_results
    search_klass.call(
      phrase: @phrase,
      kind: @kind,
      limit: @ids_limit
    )
  end
end
