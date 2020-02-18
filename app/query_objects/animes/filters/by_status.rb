class Animes::Filters::ByStatus < Animes::Filters::FilterBase
  STATUSES_EXTENDED = Types::Anime::STATUSES + %i[latest]

  StatusExtended = Types::Strict::Symbol
    .constructor(&:to_sym)
    .enum(*STATUSES_EXTENDED)

  dry_type StatusExtended
  field :status

  LATEST_INTERVAL = 3.months

  SQL_QUERIES = {
    StatusExtended[:anons] => "%<table_name>s.status = '#{Types::Anime::Status[:anons]}'",
    StatusExtended[:ongoing] => "%<table_name>s.status = '#{Types::Anime::Status[:ongoing]}'",
    StatusExtended[:released] => "%<table_name>s.status = '#{Types::Anime::Status[:released]}'",
    StatusExtended[:latest] => <<~SQL.squish
      %<table_name>s.status = '#{Types::Anime::Status[:released]}'
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
    format(
      SQL_QUERIES[term],
      table_name: table_name,
      date: sanitize(LATEST_INTERVAL.ago.to_date)
    )
  end
end
