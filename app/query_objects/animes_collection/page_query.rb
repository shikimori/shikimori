class AnimesCollection::PageQuery
  method_object [:klass, :params, :user, :limit]

  def call
    AnimesCollection::Page.new(
      collection: process(query),
      page: page,
      pages_count: pages_count,
    )
  end

private

  def page
    @page ||= (@params[:page] || 1).to_i
  end

  def pages_count
    @pages_count ||= (entries_count * 1.0 / limit).ceil
  end

  def entries_count
    size = query.size
    size.kind_of?(Hash) ? size.count : size
  end

  def process query
    query.offset(limit * (page-1)).limit(limit).to_a
  end

  def query
    AniMangaQuery.new(@klass, @params, @user).fetch
  end
end
