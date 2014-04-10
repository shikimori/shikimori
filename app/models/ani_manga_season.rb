class AniMangaSeason
  @all = [
    ['summer_2014', 'Лето 2014'],
    ['spring_2014', 'Весна 2014'],
    ['winter_2014', 'Зима 2014'],
    ['fall_2013', 'Осень 2013'],
    ['2013', '2013 год'],
    ['2012', '2012 год'],
    ['2010_2011', '2010-2011'],
    ['2005_2009', '2005-2009'],
    ['2000_2004', '2000-2004'],
    ['199x', '90е годы'],
    ['198x', '80е годы'],
    ['ancient', 'более старые']
  ]

  def self.all
    @all
  end

  def self.query_for(season, klass=Anime)
    case season
      when 'ancient'
        "aired_on <= '%s 00:00:00'" % Date.new(1980)

      when /^([a-z]+)_(\d+)$/
        year = $2.to_i
        season = $1
        date_from = nil
        date_to = nil
        additional = ""
        case season
          when 'winter'
            date_from = Date.new(year-1, 12) - 8.days
            date_to = Date.new(year, 3) - 8.days
            additional = " and aired_on != '%d:01:01 00:00:00'" % Date.new(year, 3).year

          when 'fall'
            date_from = Date.new(year, 9) - 8.days
            date_to = Date.new(year, 12) - 8.days

          when 'summer'
            date_from = Date.new(year, 6) - 8.days
            date_to = Date.new(year, 9) - 8.days

          when 'spring'
            date_from = Date.new(year, 3) - 8.days
            date_to = Date.new(year, 6) - 8.days
        end
        "(aired_on >= '%s 00:00:00' and aired_on < '%s 00:00:00'%s)" % [date_from, date_to, additional]

      when /^(\d+)$/
        "(aired_on >= '%s 00:00:00' and aired_on < '%s 00:00:00')" % [Date.new($1.to_i), Date.new($1.to_i + 1)]

      when /^(\d+)_(\d+)$/
        "(aired_on >= '%s 00:00:00' and aired_on < '%s 00:00:00')" % [Date.new($1.to_i), Date.new($2.to_i + 1)]

      when /^(\d{3})x$/
        "(aired_on >= '%s 00:00:00' and aired_on < '%s 00:00:00')" % [Date.new($1.to_i * 10), Date.new(($1.to_i + 1)*10)]

      else
        raise BadSeasonError, "unknown season '#{season}'"
    end
  end

  def self.anime_season_title(season_text)
    season_text =~ /^([a-z]+)_(\d+)$/

    year = $2.to_i
    season = $1

    case season
      when 'winter'
        "зимний аниме сезон #{year} года"

      when 'fall'
        "осенний аниме сезон #{year} года"

      when 'summer'
        "летний аниме сезон #{year} года"

      when 'spring'
        "весенний аниме сезон #{year} года"
    end
  end

  def self.title_for(season_text, klass)
    case season_text
      when 'ongoing'
        "онгоинги"

      when 'latest'
        klass == Anime ? "последние" : "последняя"

      when 'planned'
        "анонсы"

      when 'ancient'
        "древности"

      when /^([a-z]+)_(\d+)$/
        year = $2.to_i
        season = $1
        case season
          when 'winter'
            "зимы #{year}"

          when 'fall'
            "осени #{year}"

          when 'summer'
            "лета #{year}"

          when 'spring'
            "весны #{year}"
        end

      when /^(\d+)$/
        "#{$1} года"

      when /^(\d+)_(\d+)$/
        "#{$1}-#{$2} годов"

      when /^\d{2}(\d)x$/
        "#{$1}0х годов"
    end
  end
end
