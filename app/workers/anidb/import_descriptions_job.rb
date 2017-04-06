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
    db_entries.find_each do |db_entry|
      update_description_en db_entry
      update_anidb_external_link db_entry
    end
  end

  def update_description_en db_entry
    description_en = anidb_description_en db_entry
    db_entry.update! description_en: description_en
  end

  def update_anidb_external_link db_entry
    db_entry.anidb_external_link.update! imported_at: Time.zone.now
  end

  def anidb_description_en db_entry
    anidb_url = db_entry.anidb_external_link.url
    description_en = Anidb::ParseDescription.call anidb_url
    Anidb::ProcessDescription.call description_en, anidb_url
  end
end
