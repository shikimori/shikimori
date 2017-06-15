class Collections::Query < QueryObjectBase
  SEARCH_LIMIT = 999

  def self.fetch locale
    new Collection
      .includes(:topics)
      .where(locale: locale)
      .where(state: :published)
      .where.not(moderation_state: :rejected)
      .order(id: :desc)
  end

  def search phrase, locale
    return self if phrase.blank?

    chain Search::Collection.call(
      scope: @scope,
      phrase: phrase,
      locale: locale,
      ids_limit: SEARCH_LIMIT
    )
  end
end
