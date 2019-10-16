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
    collection
      .select { |v| v.linked_type == Anime.name }
      .map(&:linked)
      .map(&:decorate)
  end

  def mangas
    collection
      .select { |v| v.linked_type == Manga.name }
      .map(&:linked)
      .map(&:decorate)
  end

  def ranobe
    collection
      .select { |v| v.linked_type == Ranobe.name }
      .map(&:linked)
      .map(&:decorate)
  end

  def characters
    collection
      .select { |v| v.linked_type == Character.name }
      .map(&:linked)
      .map(&:decorate)
  end

  def seyu
    collection
      .select { |v| v.linked_type == Person.name && v.seyu? }
      .map(&:linked)
      .map(&:decorate)
  end

  def producers
    collection
      .select { |v| v.linked_type == Person.name && v.producer? }
      .map(&:linked)
      .map(&:decorate)
  end

  def mangakas
    collection
      .select { |v| v.linked_type == Person.name && v.mangaka? }
      .map(&:linked)
      .map(&:decorate)
  end

  def people
    collection
      .select { |v| v.linked_type == Person.name && v.person? }
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
