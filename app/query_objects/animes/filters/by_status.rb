class Animes::Filters::ByStatus < Animes::Filters::FilterBase
  AnimeStatus = Types::Anime::Status
  AnimeStatusExtended = Types::Strict::Symbol
    .constructor(&:to_sym)
    .enum(*(AnimeStatus.values + %i[latest]))

  MangaStatus = Types::Manga::Status
  MangaStatusExtended = Types::Strict::Symbol
    .constructor(&:to_sym)
    .enum(*(MangaStatus.values + %i[latest]))

  STATUSES_EXTENDED = {
    Anime.table_name => AnimeStatusExtended,
    Manga.table_name => MangaStatusExtended
  }

  def dry_type
    STATUSES_EXTENDED[@scope.table_name]
  end
  field :status

  LATEST_INTERVAL = 3.months

  SQL_QUERIES = {
    AnimeStatusExtended[:anons] => "%<table_name>s.status = '#{AnimeStatus[:anons]}'",
    AnimeStatusExtended[:ongoing] => "%<table_name>s.status = '#{AnimeStatus[:ongoing]}'",
    AnimeStatusExtended[:released] => "%<table_name>s.status = '#{AnimeStatus[:released]}'",
    MangaStatusExtended[:paused] => "%<table_name>s.status = '#{MangaStatus[:paused]}'",
    MangaStatusExtended[:discontinued] =>
      "%<table_name>s.status = '#{MangaStatus[:discontinued]}'",
    AnimeStatusExtended[:latest] => <<~SQL.squish
      %<table_name>s.status = '#{AnimeStatus[:released]}'
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
