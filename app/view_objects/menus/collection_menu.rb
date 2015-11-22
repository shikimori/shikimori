class Menus::CollectionMenu < ViewObjectBase
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
    [
      SeasonTitle.new(3.months.from_now, :season_year),
      SeasonTitle.new(Time.zone.now, :season_year),
      SeasonTitle.new(3.months.ago, :season_year),
      SeasonTitle.new(6.months.ago, :season_year),
      SeasonTitle.new(Time.zone.now, :year),
      SeasonTitle.new(1.year.ago, :year),
      SeasonTitle.new(2.years.ago, :years_2),
      SeasonTitle.new(4.years.ago, :years_5),
      SeasonTitle.new(9.years.ago, :years_7),
      SeasonTitle.new(Date.parse('1995-01-01'), :decade),
      SeasonTitle.new(Date.parse('1985-01-01'), :decade),
      SeasonTitle.new(nil, :ancient)
    ]
  end

private

  def load_associations
    AniMangaAssociationsQuery.new.fetch klass
  end
end
