class AnimesCollection::PageQuery
  method_object %i[klass! filters! user limit!]

  def call
    AnimesCollection::Page.new(
      collection: process(query),
      page: page,
      pages_count: pages_count
    )
  end

private

  def page
    @page ||= [filters[:page].to_i, 1].max
  end

  def pages_count
    @pages_count ||= (entries_count * 1.0 / limit).ceil
  end

  def entries_count
    size = query.size
    size.is_a?(Hash) ? size.count : size
  end

  def process query
    query.offset(limit * (page - 1)).limit(limit).to_a
  end

  def query
    scope = Animes::Query.fetch(
      scope: @klass,
      params: filters,
      user: @user
    )

    if @klass == Manga
      scope.where.not(kind: Ranobe::KINDS)
    else
      scope
    end
  end
end
