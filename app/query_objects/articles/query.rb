class Articles::Query < QueryObjectBase
  SEARCH_LIMIT = 999

  def self.fetch locale
    new Article
      .available
      .includes(:topics)
      .where(locale: locale)
      .order(id: :desc)
  end

  def search phrase, locale
    return self if phrase.blank?

    chain Search::Article.call(
      scope: @scope,
      phrase: phrase,
      locale: locale,
      ids_limit: SEARCH_LIMIT
    )
  end
end
