class Menus::TopMenu < ViewObjectBase
  def anime_seasons
    month = Time.zone.now.beginning_of_month
    # + 1.month since 12th month belongs to the next year in Titles::SeasonTitle
    is_still_this_year = (month + 2.months + 1.month).year == month.year

    [
      Titles::StatusTitle.new(:ongoing, Anime),
      Titles::SeasonTitle.new(month + 2.months, :year, Anime),
      Titles::SeasonTitle.new(is_still_this_year ? 1.year.ago : 2.months.ago, :year, Anime),
      Titles::SeasonTitle.new(month + 3.months, :season_year, Anime),
      Titles::SeasonTitle.new(month, :season_year, Anime),
      Titles::SeasonTitle.new(month - 3.months, :season_year, Anime),
      Titles::SeasonTitle.new(month - 6.months, :season_year, Anime)
    ]
  end

  def manga_kinds
    Manga.kind.values.map { |kind| Titles::KindTitle.new kind, Manga }
  end
end
