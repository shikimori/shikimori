class MigrateGenreV2Ids
  method_object :klass

  TEMP_ID = 876_564_321
  ERROR_MESSAGE = 'Something went wrong. Found GenreV2 having TEMP_ID'

  def call
    genres_v2_repository.each do |genre_v2|
      genre_v1 = Genre.find_by(name: genre_v2.name)
      next if genre_v1.nil? || genre_v1.id == genre_v2.id

      log "migrating genre_v2 (#{genre_v2.name}) id=#{genre_v2.id} to id=#{genre_v1.id}"
      migrate genre_v2:, to_id: genre_v1.id
    end
  end

private

  def migrate genre_v2:, to_id:
    raise ERROR_MESSAGE if to_id == TEMP_ID && GenreV2.find_by(id: TEMP_ID)

    from_id = genre_v2.id
    conflicting_genre_v2 = genres_v2_repository.find { |v| v.id == to_id }

    migrate genre_v2: conflicting_genre_v2, to_id: TEMP_ID if conflicting_genre_v2

    migrate_genre_id(genre_v2:, to_id:)
    migrate_db_entries(from_id:, to_id:)
    migrate_versions(from_id:, to_id:)

    log "updated genre_v2 (#{genre_v2.name}) id=#{from_id} to id=#{to_id}"
    migrate genre_v2: conflicting_genre_v2, to_id: from_id if conflicting_genre_v2
  end

  def migrate_genre_id genre_v2:, to_id:
    genre_v2.update! id: to_id
  end

  def migrate_db_entries from_id:, to_id:
    @klass
      .where("genre_v2_ids && '{#{from_id}}'")
      .update_all(
        <<~SQL.squish
          genre_v2_ids = array_append(array_remove(genre_v2_ids, '#{from_id}'), '#{to_id}')
        SQL
      )
  end

  def migrate_versions from_id:, to_id:
    Version
      .where(
        item_type: GenreV2.name,
        item_id: from_id
      )
      .update_all item_id: to_id
  end

  def genres_v2_repository
    @genres_v2_repository ||= "#{@klass.name}GenresV2Repository"
      .constantize
      .instance
  end

  def log phrase
    return if Rails.env.test?

    puts phrase # rubocop:disable Rails/Output
  end
end
