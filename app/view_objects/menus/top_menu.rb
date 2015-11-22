class Menus::TopMenu < ViewObjectBase
  def seasons
    month = Time.zone.now.beginning_of_month
    # + 1.month since 12th month belongs to the next year in SeasonTitle
    is_still_this_year = (month + 2.months + 1.month).year == month.year

    [
      StatusTitle.new(:ongoing, Anime),
      SeasonTitle.new(month + 2.months, :year),
      SeasonTitle.new(is_still_this_year ? 1.year.ago : month, :year),
      SeasonTitle.new(month + 3.months, :season_year),
      SeasonTitle.new(month, :season_year),
      SeasonTitle.new(month - 3.months, :season_year),
      SeasonTitle.new(month - 6.months, :season_year)
    ]
  end
end
