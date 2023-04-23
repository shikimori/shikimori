class MangaGenresV2Repository < AnimeGenresV2Repository
  private

  def scope_entry_type
    Types::GenreV2::EntryType['Manga']
  end
end
