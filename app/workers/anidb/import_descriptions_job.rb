# frozen_string_literal: true

class Anidb::ImportDescriptionsJob
  include Sidekiq::Worker
  # sidekiq_options retry: false

  def perform
    import_descriptions(animes)
    import_descriptions(mangas)
  end

  private

  def animes
    Anidb::ImportDescriptionsQuery.for_import(Anime)
  end

  def mangas
    Anidb::ImportDescriptionsQuery.for_import(Manga)
  end

  def import_descriptions db_entries
    db_entries.find_each { |v| import_description(v) }
  end

  def import_description db_entry
    update_description_en(db_entry)
    update_anidb_external_link(db_entry)
  rescue InvalidIdError => e
    NamedLogger.import_descriptions.error(e.message)
    db_entry.anidb_external_link.destroy
  end

  def update_description_en db_entry
    description_en = anidb_description_en(db_entry)

    if description_en.present?
      db_entry.update! description_en: description_en
    end
  end

  def anidb_description_en db_entry
    anidb_url = db_entry.anidb_external_link.url
    description_en = parse_description(anidb_url)
    Anidb::ProcessDescription.call description_en, anidb_url
  end

  def parse_description anidb_url
    Retryable.retryable tries: 10, on: AutoBannedError, sleep: 0 do
      Anidb::ParseDescription.call anidb_url
    end
  end

  def update_anidb_external_link db_entry
    db_entry.anidb_external_link.update! imported_at: Time.zone.now
  end
end
