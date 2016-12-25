class Repos::MangaGenres < Repos::RepositoryBase
private

  def scope
    Genre.where(kind: :manga)
  end
end
