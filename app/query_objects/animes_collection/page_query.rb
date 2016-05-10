class AnimesCollection::PageQuery
  pattr_initialize :params, :klass

  def fetch
    AnimesCollection::Page.new(
      collection: collection,
      page: 1,
      pages_count: 1,
    )
  end

private

  def collection
    AniMangaQuery.new(klass, params).fetch
  end
end
