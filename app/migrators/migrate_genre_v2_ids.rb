class MigrateGenreV2Ids
  method_object :klass

  TEMP_ID = 876_564_321
  ERROR_MESSAGE = 'Something went wrong. Found GenreV2 having TEMP_ID'

  SPECIAL_MIGRATION_RULES = {
    'Гонки' => 'Машины',
    'Авангард' => 'Безумие',
    'Мифология' => 'Демоны',
    'Тайна' => 'Детектив',
    'Стратегические игры' => 'Игры',
    'Детектив' => 'Полиция',
    'Кроссдрессинг' => 'Смена пола'
  }

  def call
    genres_v2_repository.each do |genre_v2|
      genre_v1 = search_maching_genre_v1(genre_v2:)
      next if genre_v1.nil? || genre_v1.id == genre_v2.id

      log "migrating #{genre_log_details genre_v2:} => id=#{genre_v1.id}"
      ActiveRecord::Base.transaction do
        migrate genre_v2:, to_id: genre_v1.id
      end
    end

    true
  end

  def migrate genre_v2:, to_id:
    raise ERROR_MESSAGE if to_id == TEMP_ID && GenreV2.find_by(id: TEMP_ID)

    from_id = genre_v2.id
    conflicting_genre_v2 = search_conflicting_genre_v2 to_id

    if conflicting_genre_v2
      log "found conflicting #{genre_log_details genre_v2: conflicting_genre_v2}"
      migrate genre_v2: conflicting_genre_v2, to_id: TEMP_ID
    end

    migrate_genre_id(genre_v2:, to_id:)
    migrate_db_entries(genre_v2:, from_id:, to_id:)
    migrate_versions(from_id:, to_id:)

    log "updated #{genre_log_details genre_v2:, id: from_id} => id=#{to_id}"
    migrate genre_v2: conflicting_genre_v2, to_id: from_id if conflicting_genre_v2
  end

private

  def search_maching_genre_v1 genre_v2:
    if SPECIAL_MIGRATION_RULES.key? genre_v2.russian
      Genre.find_by(
        russian: SPECIAL_MIGRATION_RULES[genre_v2.russian],
        kind: genre_v2.entry_type.downcase
      )
    else
      genre_v1 = Genre.find_by name: genre_v2.name, kind: genre_v2.entry_type.downcase

      if SPECIAL_MIGRATION_RULES.value? genre_v1&.russian
        nil
      else
        genre_v1
      end
    end
  end

  def search_conflicting_genre_v2 to_id
    genres_v2_repository.find { |v| v.id == to_id } ||
      genres_v2_other_repository.find { |v| v.id == to_id }
  end

  def migrate_genre_id genre_v2:, to_id:
    genre_v2.update! id: to_id
  end

  def migrate_db_entries genre_v2:, from_id:, to_id:
    genre_v2.entry_type.constantize
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

  def genres_v2_other_repository
    @genres_v2_other_repository ||= "#{(@klass == Anime ? Manga : Anime).name}GenresV2Repository"
      .constantize
      .instance
  end

  def log phrase
    return if Rails.env.test?

    NamedLogger.genres_migration.info phrase
    puts phrase # rubocop:disable Rails/Output
  end

  def genre_log_details genre_v2:, id: genre_v2.id
    "genre_v2 (#{genre_v2.entry_type} \"#{genre_v2.name}\") id=#{id}"
  end
end
