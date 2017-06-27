class AnimesCollection::PageQuery
  method_object %i[klass params user limit is_all_manga]

  def call
    AnimesCollection::Page.new(
      collection: process(query),
      page: page,
      pages_count: pages_count
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
    size.is_a?(Hash) ? size.count : size
  end

  def process query
    query.offset(limit * (page - 1)).limit(limit).to_a
  end

  def query
    scope = AniMangaQuery.new(@klass, @params, @user).fetch

    if @klass == Manga && !@is_all_manga
      scope.where.not(kind: Ranobe::KIND)
    else
      scope
    end
  end
end
