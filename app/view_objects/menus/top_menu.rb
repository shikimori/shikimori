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
    (Manga.kind.values - %w[novel]).map do |kind|
      Titles::KindTitle.new kind, Manga
    end
  end

  def ranobe_seasons
    month = Time.zone.now.beginning_of_month
    # + 1.month since 12th month belongs to the next year in Titles::SeasonTitle
    is_still_this_year = (month + 2.months + 1.month).year == month.year

    [
      Titles::StatusTitle.new(:ongoing, Ranobe),
      Titles::SeasonTitle.new(month + 2.months, :year, Ranobe),
      Titles::SeasonTitle.new(
        is_still_this_year ? 1.year.ago : 2.months.ago, :year, Ranobe
      ),
      Titles::SeasonTitle.new(
        is_still_this_year ? 2.years.ago : 14.months.ago, :year, Ranobe
      ),
      Titles::SeasonTitle.new(
        is_still_this_year ? 3.years.ago : 26.months.ago, :year, Ranobe
      )
    ].compact
  end
end
