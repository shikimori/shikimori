class Animes::Filters::ByStatus < Animes::Filters::FilterBase
  STATUSES_EXTENDED = Types::Anime::STATUSES + %i[latest]

  StatusExtended = Types::Strict::Symbol
    .constructor(&:to_sym)
    .enum(*STATUSES_EXTENDED)

  dry_type StatusExtended

  LATEST_INTERVAL = 3.months

  SQL_QUERIES = {
    StatusExtended[:anons] => "status = '#{Types::Anime::Status[:anons]}'",
    StatusExtended[:ongoing] => "status = '#{Types::Anime::Status[:ongoing]}'",
    StatusExtended[:released] => "status = '#{Types::Anime::Status[:released]}'",
    StatusExtended[:latest] => <<~SQL.squish
      status = '#{Types::Anime::Status[:released]}'
        and released_on is not null
        and released_on >= %<date>s
    SQL
  }

  def call
    scope = @scope

    if positives.any?
      sql = positives.map { |term| format_sql term }.join(' or ')
      scope = scope.where(sql)
    end

    if negatives.any?
      sql = negatives.map { |term| format_sql term }.join(' or ')
      scope = scope.where("not (#{sql})")
    end

    scope
  end

private

  def format_sql term
    term == StatusExtended[:latest] ?
      format(SQL_QUERIES[term], date: sanitize(LATEST_INTERVAL.ago.to_date)) :
      SQL_QUERIES[term]
  end
end
