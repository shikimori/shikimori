class Animes::Filters::BySeason < Animes::Filters::FilterBase
  ANCIENT_SEASON = 'ancient'

  def call
    scope = @scope

    if positives.any?
      sql = positives.map { |term| parse term }.join(' or ')
      scope = scope.where(sql)
    end

    if negatives.any?
      sql = negatives.map { |term| parse term }.join(' or ')
      scope = scope.where("not (#{sql})")
    end

    scope
  end

private

  def parse season # rubocop:disable MethodLength
    case season
      when /^(?<season>[a-z]+)_(?<year>\d{4})$/
        season_sql $LAST_MATCH_INFO[:year].to_i, $LAST_MATCH_INFO[:season]

      when /^\d{4}$/
        year_sql season.to_i

      when /^(?<year_from>\d{4})_(?<year_to>\d{4})$/
        years_sql(
          $LAST_MATCH_INFO[:year_from].to_i,
          $LAST_MATCH_INFO[:year_to].to_i
        )

      when /^(?<decade>\d{3})x$/
        decade_sql $LAST_MATCH_INFO[:decade].to_i

      when ANCIENT_SEASON
        ancient_sql

      else
        raise InvalidParameterError.new(:season, season)
    end
  end

  def season_sql year, season # rubocop:disable MethodLength, AbcSize
    date_from = nil
    date_to = nil
    additional = ''

    case season
      when 'winter'
        date_from = Date.new(year, 1) - 9.days
        date_to = Date.new(year, 4) - 9.days
        additional = " and aired_on->'month' is not null"

      when 'spring'
        date_from = Date.new(year, 4) - 9.days
        date_to = Date.new(year, 7) - 9.days

      when 'summer'
        date_from = Date.new(year, 7) - 9.days
        date_to = Date.new(year, 10) - 9.days

      when 'fall'
        date_from = Date.new(year, 10) - 9.days
        date_to = Date.new(year + 1, 1) - 9.days

      else
        raise InvalidParameterError.new(:@season, @season)
    end

    <<~SQL.squish
      aired_on_computed >= '#{date_from}' and aired_on_computed < '#{date_to}'#{additional}
    SQL
  end

  def year_sql year
    <<~SQL.squish
      aired_on_computed >= '#{Date.new year}' and aired_on_computed < '#{Date.new(year + 1)}'
    SQL
  end

  def years_sql year_from, year_to
    <<~SQL.squish
      aired_on_computed >= '#{Date.new year_from}' and
        aired_on_computed < '#{Date.new(year_to + 1)}'
    SQL
  end

  def decade_sql decade
    <<~SQL.squish
      aired_on_computed >= '#{Date.new(decade * 10)}' and
        aired_on_computed < '#{Date.new((decade + 1) * 10)}'
    SQL
  end

  def ancient_sql
    <<~SQL.squish
      aired_on_computed <= '#{Date.new 1980}'
    SQL
  end
end
