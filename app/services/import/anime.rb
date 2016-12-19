class Import::Anime < Import::Base
  SPECIAL_FIELDS = %i(
    genres studios related
  )

private

  def assign_genres genres
  end

  def assign_studios studios
  end

  def assign_related related
  end

  def klass
    Anime
  end
end
