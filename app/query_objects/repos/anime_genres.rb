class Repos::AnimeGenres < Repos::RepositoryBase
private

  def scope
    Genre.where kind: :anime
  end
end
