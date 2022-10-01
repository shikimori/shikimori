class Search::Topic < Search::SearchBase
  method_object %i[scope! phrase! forum_id! ids_limit!]

  def elastic_results
    search_klass.call(
      phrase: @phrase,
      forum_id: @forum_id,
      limit: @ids_limit
    )
  end
end
