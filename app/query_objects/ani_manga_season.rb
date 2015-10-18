class AniMangaSeason
  extend Translation

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
          i18n_t 'winter_season', year: year

        when 'spring'
          i18n_t 'spring_season', year: year

        when 'summer'
          i18n_t 'summer_season', year: year

        when 'fall'
          i18n_t 'fall_season', year: year
      end
    end

    def title_for season_text, klass
      case season_text
        when 'ongoing'
          i18n_i 'ongoing', :other

        when 'latest'
          i18n_t "latest_#{klass.downcase}"

        when 'planned'
          i18n_t 'planned'

        when 'ancient'
          i18n_t 'old'

        when /^([a-z]+)_(\d+)$/
          year = $2.to_i
          season = $1

          case season
            when 'winter'
              i18n_t 'winters_year', year: year

            when 'spring'
              i18n_t 'springs_year', year: year

            when 'summer'
              i18n_t 'summers_year', year: year

            when 'fall'
              i18n_t 'falls_year', year: year
          end

        when /^(\d+)$/
          i18n_t 'of.year', year: $1

        when /^(\d+)_(\d+)$/
          i18n_t 'of.years', from: $1, to: $2

        when /^\d{2}(\d)x$/
          i18n_t 'of.decade', decade: $1
      end
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
