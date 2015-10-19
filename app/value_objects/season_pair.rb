class SeasonPair
  include Translation

  pattr_initialize :date

  def season_year
    [
      "#{extract_season date}_#{extract_year date}",
      i18n_t("season.#{extract_season date}", year: extract_year(date))
    ]
  end

  def year
    [
      extract_year(date).to_s,
      i18n_t('year', year: extract_year(date))
    ]
  end

  def years interval
    year_from = extract_year(date - interval.years) + 1
    year_to = extract_year(date)

    [
      "#{year_from}_#{year_to}",
      "#{year_from}-#{year_to}"
    ]
  end

  def decade
    year = date.year.to_s

    [
      year.sub(/\d$/, 'x'),
      i18n_t('decade', decade: year[0..2])
    ]
  end

  def ancient
    ['ancient', i18n_t('ancient')]
  end

private

  def extract_season date
    case date.month
      when 1,2,12 then 'winter'
      when 3,4,5 then 'spring'
      when 6,7,8 then 'summer'
      else 'fall'
    end
  end

  def extract_year date
    date.month == 12 ? date.year + 1 : date.year
  end
end
