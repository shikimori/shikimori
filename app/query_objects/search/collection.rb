class Search::Collection < Search::SearchBase
  method_object %i[scope! phrase! ids_limit!]

  TAGS_PARSE_REGEXP = /,?\s*(?=#)/

  ANIME_TAG = Tags::CleanupForumTag::ANIME_TAG
  MANGA_TAG = Tags::CleanupForumTag::MANGA_TAG
  RANOBE_TAG = Tags::CleanupForumTag::RANOBE_TAG
  CHARACTER_TAG = Tags::CleanupForumTag::CHARACTER_TAG
  PERSON_TAG = Tags::CleanupForumTag::PERSON_TAG

  KIND_TAGS = {
    ANIME_TAG => Types::Collection::Kind[:anime],
    MANGA_TAG => Types::Collection::Kind[:manga],
    RANOBE_TAG => Types::Collection::Kind[:ranobe],
    CHARACTER_TAG => Types::Collection::Kind[:character],
    PERSON_TAG => Types::Collection::Kind[:person]
  }

  def call
    return super unless tags_search?

    scope = @scope
    scope = filter_by_kinds scope, kind_tags if kind_tags.any?
    scope = filter_by_tags scope, phrase_tags if non_kind_tags.any?

    scope
      .limit(@ids_limit)
      .order(Arel.sql('(cached_votes_up - cached_votes_down) desc, name'))
  end

private

  def elastic_results
    search_klass.call(
      phrase: @phrase,
      limit: @ids_limit
    )
  end

  def filter_by_kinds scope, kinds
    kinds.inject(scope) do |memo, kind|
      memo.where 'tags @> array[:tag] or kind = :kind',
        tag: kind,
        kind: KIND_TAGS[kind]
    end
  end

  def filter_by_tags scope, tags
    scope.where('tags @> array[?]', tags)
  end

  def phrase_tags
    @phrase_tags ||= @phrase
      .split(TAGS_PARSE_REGEXP)
      .map { |token| Tags::CleanupForumTag.call token }
  end

  def kind_tags
    @kind_tags ||= phrase_tags.select { |tag| KIND_TAGS.include? tag }
  end

  def non_kind_tags
    phrase_tags - kind_tags
  end

  def tags_search?
    @phrase.starts_with?('#')
  end
end
