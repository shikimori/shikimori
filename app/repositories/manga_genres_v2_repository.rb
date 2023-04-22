class MangaGenresV2Repository < AnimeGenresV2Repository
  private

  def scope_entry_type
    Types::Genre::EntryType['Manga']
  end
end
