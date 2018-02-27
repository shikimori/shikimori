class Titles::SeasonTitle
  include Translation

  YEARS_INTERVAL = /years_(?<years>\d+)/

  pattr_initialize :date, :format, :klass

  def text
    case format
      when :season_year
        "#{season}_#{year}"

      when :year
        year

      when YEARS_INTERVAL
        "#{year_from}_#{year_to}"

      when :decade
        year.sub(/\d$/, 'x')

      when :ancient
        'ancient'

      else
        raise ArgumentError, "unexpected format #{format}"
    end
  end

  def url_params
    # без nil из-за странного бага рельс когда находишься на странице
    # http://shikimori.local/animes/status/anons status/anons попадает
    # в сгенерённый url
    { season: text, status: nil, type: nil }
  end

  def catalog_title
    localize :catalog
  end

  def short_title
    localize :short
  end

  def full_title
    localize :full
  end

private

  def localize key
    case format
      when :season_year
        i18n_t "#{klass.name.downcase}.#{key}.season.#{season}", year: year

      when :year
        i18n_t "#{klass.name.downcase}.#{key}.year", year: year

      when YEARS_INTERVAL
        "#{year_from}-#{year_to}"

      when :decade
        i18n_t "#{klass.name.downcase}.#{key}.decade", decade: year[0..2]

      when :ancient
        i18n_t "#{klass.name.downcase}.#{key}.ancient"

      else
        raise ArgumentError, "unexpected format #{format}"
    end
  end

  def season
    case date.month
      when 1, 2, 12 then 'winter'
      when 3, 4, 5 then 'spring'
      when 6, 7, 8 then 'summer'
      else 'fall'
    end
  end

  def year
    (date.month == 12 ? date.year + 1 : date.year).to_s
  end

  def year_to
    year if format =~ YEARS_INTERVAL
  end

  def year_from
    year.to_i - $~[:years].to_i + 1 if format =~ YEARS_INTERVAL
  end
end
