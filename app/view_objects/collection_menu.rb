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

  def seasons
    month = Time.zone.now.beginning_of_month
    Hash[
      [
        SeasonPair.new(month + 3.months).season_year,
        SeasonPair.new(month).season_year,
        SeasonPair.new(month - 3.months).season_year,
        SeasonPair.new(month - 6.months).season_year,
        SeasonPair.new(month).year,
        SeasonPair.new(month - 1.year).year,
        SeasonPair.new(month - 2.years).years(2),
        SeasonPair.new(month - 4.years).years(5),
        SeasonPair.new(month - 9.years).years(7),
        SeasonPair.new(Date.parse '1995-01-01').decade,
        SeasonPair.new(Date.parse '1985-01-01').decade,
        SeasonPair.new(nil).ancient
      ]
    ]
  end

private

  def load_associations
    AniMangaAssociationsQuery.new.fetch klass
  end
end
