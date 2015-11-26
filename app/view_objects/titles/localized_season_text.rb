class Titles::LocalizedSeasonText
  include Translation

  pattr_initialize :klass, :season_text

  def title
    case season_text
      when 'ongoing'
        i18n_i 'ongoing', :other

      when 'latest'
        i18n_t "latest_#{klass.name.downcase}"

      when 'planned'
        i18n_t 'planned'

      when 'ancient'
        i18n_t 'old'

      when /^([a-z]+)_(\d+)$/
        year = $2.to_i
        season = $1

        case season
          when 'winter'
            i18n_t 'winter_year', year: year

          when 'spring'
            i18n_t 'spring_year', year: year

          when 'summer'
            i18n_t 'summer_year', year: year

          when 'fall'
            i18n_t 'fall_year', year: year
        end

      when /^(\d+)$/
        i18n_t 'of.year', year: $1

      when /^(\d+)_(\d+)$/
        i18n_t 'of.years', from: $1, to: $2

      when /^\d{2}(\d)x$/
        i18n_t 'of.decade', decade: $1
    end
  end
end
