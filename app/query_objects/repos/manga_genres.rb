class Repos::MangaGenres < Repos::AnimeGenres
private

  def scope
    Genre.where(kind: :manga).order(:position)
  end
end
