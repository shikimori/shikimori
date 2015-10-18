class CollectionMenu < ViewObjectBase
  vattr_initialize :klass
  instance_cache :load_associations

  def url
    h.send "menu_#{klass.name.tableize}_url", rating: h.params[:rating], subdomain: false
  end

  def sorted_genres
    genres.sort_by { |v| [v.position || v.id, h.localized_name(v)] }
  end

  def genres
    @genres || load_associations.first
  end

  def studios
    @studios || load_associations.second
  end

  def publishers
    @publishers || load_associations.third
  end

private

  def load_associations
    AniMangaAssociationsQuery.new.fetch klass
  end
end
