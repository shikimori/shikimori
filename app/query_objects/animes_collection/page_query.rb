class AnimesCollection::PageQuery
  pattr_initialize :params, :klass

  LIMIT = 20

  def fetch
    AnimesCollection::Page.new(
      collection: process(query),
      page: page,
      pages_count: pages_count,
    )
  end

private

  def page
    (params[:page] || 1).to_i
  end

  def pages_count
    (query.size * 1.0 / limit).ceil
  end

  def limit
    LIMIT
  end

  def process query
    query.offset(limit * (page-1)).limit(limit)
  end

  def query
    AniMangaQuery.new(klass, params).fetch
  end
end
