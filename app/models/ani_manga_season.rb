class AniMangaSeason
  class << self
    def query_for season, klass=Anime
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
              additional = " and aired_on != '#{Date.new(year, 3).year}-01-01'"

            when 'fall'
              date_from = Date.new(year, 9) - 8.days
              date_to = Date.new(year, 12) - 8.days

            when 'summer'
              date_from = Date.new(year, 6) - 8.days
              date_to = Date.new(year, 9) - 8.days

            when 'spring'
              date_from = Date.new(year, 3) - 8.days
              date_to = Date.new(year, 6) - 8.days

            else
              raise BadSeasonError, "unknown season '#{season}'"
          end
          "(aired_on >= '#{date_from}' and aired_on < '#{date_to}'#{additional})"

        when /^(\d+)$/
          "(aired_on >= '#{Date.new($1.to_i)}' and aired_on < '#{Date.new($1.to_i + 1)}')"

        when /^(\d+)_(\d+)$/
          "(aired_on >= '#{Date.new($1.to_i)}' and aired_on < '#{Date.new($2.to_i + 1)}')"

        when /^(\d{3})x$/
          "(aired_on >= '#{Date.new($1.to_i * 10)}' and aired_on < '#{Date.new(($1.to_i + 1)*10)}')"

        else
          raise BadSeasonError, "unknown season '#{season}'"
      end
    end

    def anime_season_title season_text
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

    def title_for season_text, klass
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

    def catalog_seasons
      month = Time.zone.now.beginning_of_month
      [
        date_to_season(month + 3.months),
        date_to_season(month),
        date_to_season(month - 3.months),
        date_to_season(month - 6.months),
        month.year.to_s,
        (month.year - 1).to_s,
      ].map do |season|
        [season, catalog_to_s(season)]
      end + [
        ["#{month.year-3}_#{month.year - 2}", "#{month.year-3}-#{month.year - 2}"],
        ["#{month.year-8}_#{month.year - 4}", "#{month.year-8}-#{month.year - 4}"],
        ["2000_#{month.year - 9}", "2000-#{month.year - 9}"],
        ['199x', '90е годы'],
        ['198x', '80е годы'],
        ['ancient', 'более старые']
      ]
    end

    def menu_seasons
      month = Time.zone.now.beginning_of_month
      [
        (month + 2.months).year.to_s,
        (month + 2.months).year == month.year ? (month.year - 1).to_s : month.year.to_s,
        date_to_season(month + 3.months),
        date_to_season(month),
        date_to_season(month - 3.months),
        date_to_season(month - 6.months),
      ].map do |season|
        [season, menu_to_s(season, true), menu_to_s(season, false)]
      end
    end

  private
    def catalog_to_s season
      if season =~ /^\d+$/
        "#{season} год"
      elsif season =~ /spring/
        season.sub 'spring_', 'Весна '
      elsif season =~ /summer/
        season.sub 'summer_', 'Лето '
      elsif season =~ /fall/
        season.sub 'fall_', 'Осень '
      elsif season =~ /winter/
        season.sub 'winter_', 'Зима '
      end
    end

    def menu_to_s season, is_short
      if season =~ /^\d+$/
        is_short ? "#{season} год" : "Аниме #{season} года"
      elsif season =~ /spring_(?<year>\d+)/
        is_short ? 'Весенний сезон' : "Весенний сезон #{$~[:year]} года"
      elsif season =~ /summer_(?<year>\d+)/
        is_short ? 'Летний сезон' : "Летний сезон #{$~[:year]} года"
      elsif season =~ /fall_(?<year>\d+)/
        is_short ? 'Осенний сезон' : "Осенний сезон #{$~[:year]} года"
      elsif season =~ /winter_(?<year>\d+)/
        is_short ? 'Зимний сезон' : "Зимний сезон #{$~[:year]} года"
      end
    end

    def date_to_season date
      "#{month_to_string date.month}_#{date.month == 12 ? date.year + 1 : date.year}"
    end

    def month_to_string month
      case month
        when 1,2,12 then 'winter'
        when 3,4,5 then 'spring'
        when 6,7,8 then 'summer'
        else 'fall'
      end
    end
  end
end
