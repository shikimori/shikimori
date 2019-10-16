class Profiles::FavoritesView < ViewObjectBase
  vattr_initialize :user
  instance_cache :collection,
    :fav_animes

  def collection
    scope.includes(:linked).ordered.to_a
  end

  def fav_animes
    collection
      .select { |v| v.linked_type == Anime.name }
      .map(&:linked)
      .map(&:decorate)
  end

  def cache_key
    [scope, :v1]
  end

private

  def scope
    @user.favourites
  end
end
