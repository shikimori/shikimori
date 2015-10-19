class MenuSeasonPair < SeasonPair
  def season_year
    [
      "#{extract_season date}_#{extract_year date}",
      i18n_t("short.season.#{extract_season date}"),
      i18n_t("full.season.#{extract_season date}", year: extract_year(date))
    ]
  end

  def year
    [
      extract_year(date).to_s,
      i18n_t('short.year', year: extract_year(date)),
      i18n_t('full.year', year: extract_year(date))
    ]
  end
end
