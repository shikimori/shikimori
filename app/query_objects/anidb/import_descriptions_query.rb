# frozen_string_literal: true

class Anidb::ImportDescriptionsQuery
  MAL_SOURCE = '%[source]http://myanimelist.net/anime/%[/source]'

  class << self
    def for_import db_entry_relation
      db_entry_relation
        .includes(:anidb_external_link)
        .joins(:external_links)
        .where("
          description_en LIKE '#{MAL_SOURCE}' OR
          description_en = '' OR
          description_en IS NULL
        ".squish)
        .where(external_links: { imported_at: nil })
        .where(external_links: { kind: Types::ExternalLink::Kind[:anime_db] })
        .order(:ranked)
    end
  end
end
