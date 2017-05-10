class CollectionsQuery < SimpleQueryBase
  pattr_initialize :locale

private

  def query
    Collection
      .where(locale: @locale)
      .where(state: :published)
      .order(:id)
  end
end
