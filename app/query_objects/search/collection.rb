class Search::Collection < Search::SearchBase
  method_object %i[scope! phrase! ids_limit!]

  TAGS_PARSE_REGEXP = /,?\s*(?=#)/
  TAG_MAPPINGS = {
    'anime' => 'аниме',
    'анимэ' => 'аниме',
    'анімэ' => 'аниме',
    'manga' => 'манга',
    'ranobe' => 'ранобэ',
    'ранобе' => 'ранобэ'
  }

  def call
    return super unless tags_search?

    @scope
      .where('tags @> array[?]', phrase_tags)
      .limit(@ids_limit)
      .order(Arel.sql('(cached_votes_up - cached_votes_down) desc, name'))
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
      .map { |token| Tags::CleanupForumTag.call token }
  end

  def tags_search?
    @phrase.starts_with?('#')
  end
end
