class Search::Person < Search::SearchBase
  method_object %i[scope phrase ids_limit is_mangaka is_producer is_seyu]

private

  def elastic_results
    search_klass.call(
      phrase: @phrase,
      limit: @ids_limit,
      is_mangaka: @is_mangaka,
      is_producer: @is_producer,
      is_seyu: @is_seyu
    )
  end
end
