class Search::Collection < Search::SearchBase
  method_object %i[scope! phrase! ids_limit!]

  TAGS_PARSE_REGEXP = /,?\s*(?=#)/

  def call
    return super unless tags_search?

    @scope
      .where('tags @> array[?]', phrase_tags)
      .limit(@ids_limit)
  end

  def elastic_results
    search_klass.call(
      phrase: @phrase,
      limit: @ids_limit
    )
  end

  def phrase_tags
    @phrase
      .split(TAGS_PARSE_REGEXP)
      .pluck(1..)
  end

  def tags_search?
    @phrase.starts_with?('#')
  end
end
