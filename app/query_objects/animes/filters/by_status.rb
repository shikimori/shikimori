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
        and released_on >= (now() - interval '#{LATEST_INTERVAL.to_i} seconds')::date
    SQL
  }

  def call
    scope = @scope

    if positives.any?
      sql = positives.map { |term| SQL_QUERIES[term] }.join(' or ')
      scope = scope.where(sql)
    end

    if negatives.any?
      sql = negatives.map { |term| SQL_QUERIES[term] }.join(' or ')
      scope = scope.where("not (#{sql})")
    end

    scope
  end
end
