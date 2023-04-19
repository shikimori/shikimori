class MangaGenresRepository < AnimeGenresRepository
  private

  def scope
    Genre.where(entry_type: Types::Genre::EntryType['Manga']).order(:position)
  end
end
