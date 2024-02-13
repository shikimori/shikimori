class MigrateGenreV2Ids
  method_object :klass

  TEMP_ID = 9_876_564_321
  ERROR_MESSAGE = 'Something went wrong. Found GenreV2 having TEMP_ID'

  def call
    genres_v2_repository.each do |genre_v2|
      genre_v1 = Genre.find_by(name: genre_v2.name)
      next if genre_v1.nil? || genre_v1.id == genre_v2.id

      ap "Migrating GenreV2 NAME=#{genre_v2.name} ID=#{genre_v2.id} to ID=#{genre_v1.id}"
      migrate genre_v2:, to_id: genre_v1.id
    end
  end

private

  def migrate genre_v2:, to_id:
    raise ERROR_MESSAGE if to_id == TEMP_ID && GenreV2.find_by(id: TEMP_ID)

    from_id = genre_v2.id
    conflicting_genre_v2 = genres_v2_repository.find { |v| v.id == to_id }

    migrate genre_v2: conflicting_genre_v2, to_id: TEMP_ID if conflicting_genre_v2
    genre_v2.update! id: to_id
    ap "Changed GenreV2 NAME=#{genre_v2.name} ID=#{from_id} to ID=#{to_id}"
    migrate genre_v2: conflicting_genre_v2, to_id: from_id if conflicting_genre_v2
  end

  def genres_v2_repository
    @genres_v2_repository ||= "#{@klass.name}GenresV2Repository"
      .constantize
      .instance
  end
end
