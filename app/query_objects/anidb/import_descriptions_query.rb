# frozen_string_literal: true

class Anidb::ImportDescriptionsQuery
  MAL_SOURCE = '%[source]http://myanimelist.net/anime/%[/source]'

  DESCRIPTION_SQL = <<-SQL.squish
    description_en LIKE '#{MAL_SOURCE}' OR
    description_en = '' OR
    description_en IS NULL
  SQL
  ORDER_SQL = <<-SQL.squish
    (case
      when popularity=0
      then 999999
      else popularity
    end), (case
      when is_censored=true
      then 2
      else 1
    end),
    id asc
  SQL

  class << self
    def for_import db_entry_relation
      db_entry_relation
        .includes(:anidb_external_link)
        .joins(:external_links)
        .where(Arel.sql(DESCRIPTION_SQL))
        .where(external_links: { imported_at: nil })
        .where(external_links: { kind: Types::ExternalLink::Kind[:anime_db] })
        .order(Arel.sql(ORDER_SQL))
    end
  end
end
