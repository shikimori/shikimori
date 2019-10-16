class Profiles::FavoritesView < ViewObjectBase
  vattr_initialize :user
  instance_cache :collection,
    :animes,
    :mangas,
    :ranobe,
    :characters,
    :seyu,
    :producers,
    :mangakas,
    :people

  def collection
    scope.includes(:linked).ordered.to_a
  end

  def animes
    build(
      collection.select { |v| v.linked_type == Anime.name }
    )
  end

  def mangas
    build(
      collection.select { |v| v.linked_type == Manga.name }
    )
  end

  def ranobe
    build(
      collection.select { |v| v.linked_type == Ranobe.name }
    )
  end

  def characters
    build(
      collection.select { |v| v.linked_type == Character.name }
    )
  end

  def seyu
    build(
      collection.select { |v| v.linked_type == Person.name && v.seyu? }
    )
  end

  def producers
    build(
      collection.select { |v| v.linked_type == Person.name && v.producer? }
    )
  end

  def mangakas
    build(
      collection.select { |v| v.linked_type == Person.name && v.mangaka? }
    )
  end

  def people
    build(
      collection.select { |v| v.linked_type == Person.name && v.person? }
    )
  end

  def cache_key
    scope
  end

private

  def scope
    @user.favourites
  end

  def build collection
    collection.map do |favorite|
      FavoriteEntry.new favorite.linked.decorate, favorite
    end
  end
end
