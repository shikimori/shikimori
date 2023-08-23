class MangaGenresRepository < AnimeGenresRepository
  private

  def scope
    Genre.where(kind: 'manga').order(:position)
  end
end
