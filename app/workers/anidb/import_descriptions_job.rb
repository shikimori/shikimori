class Anidb::ImportDescriptions < ActiveJob::Base
  def perform
    import_anime_descriptions
    import_manga_descriptions
  end

  private

  # TODO: use chainable_methods?
  def import_anime_descriptions
    animes.find_each do |v|
      anidb_url = v.anidb_external_link.url
      value = Anidb::ParseDescription.new.(anidb_url)
      description = Anidb::ProcessDescription.new.(value, anidb_url)
    end
  end

  def import_manga_descriptions

  end

  def animes
    Anidb::ImportDescriptionsQuery.for_import(Anime)
  end

  def mangas
    Anidb::ImportDescriptionsQuery.for_import(Manga)
  end
end
