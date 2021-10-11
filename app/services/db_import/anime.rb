class DbImport::Anime < DbImport::ImportBase
  SPECIAL_FIELDS = %i[
    image synopsis
    genres studios related recommendations characters
    external_links
  ]
  IGNORED_FIELDS = %i[members favorites]

private

  def assign_synopsis synopsis
    super unless anidb_synopsis? && entry.description_en.present?
  end

  def assign_genres genres
    unless :genre_ids.in? desynced_fields
      entry.genre_ids = preprocess_genres(genres)
        .map { |v| import_genre(v).id }
    end

    assign_is_censored
  end

  def assign_is_censored
    return if :is_censored.in? desynced_fields

    entry.is_censored = entry.rating_rx? || entry.genres.any?(&:censored?)
  end

  def import_genre data
    genre = genres_repository.find_by_mal_id data[:id] # rubocop:disable DynamicFindBy
    raise ArgumentError, "mismatched genre: #{data.to_json}" unless genre.name == data[:name]

    genre
  rescue ActiveRecord::RecordNotFound
    raise ArgumentError, "unknown genre: #{data.to_json}"
  end

  def assign_studios studios
    entry.studio_ids = studios.map { |v| sync_studio(v).id }
  end

  def sync_studio data
    studio = StudiosRepository.instance.find data[:id]

    if studio.name != data[:name] && studio.desynced.exclude?('name')
      studio.update! name: data[:name]
    end

    studio
  rescue ActiveRecord::RecordNotFound
    Studio.create!(
      id: data[:id],
      name: data[:name],
      is_visible: false
    )
  end

  def assign_related related
    DbImport::Related.call entry, related
  end

  def assign_recommendations similarities
    DbImport::Similarities.call entry, similarities
  end

  def assign_external_links external_links
    DbImport::ExternalLinks.call entry, external_links
  end

  def assign_characters data
    if data[:characters].any? || data[:staff].any?
      DbImport::PersonRoles.call entry, data[:characters], data[:staff]
    end
  end

  def anidb_synopsis?
    entry.all_external_links.any? do |external_link|
      external_link.kind_anime_db? && external_link.imported_at.present?
    end
  end

  def preprocess_genres genres # rubocop:disable all
    has_erotica = genres.any? { |genre| genre[:name] == 'Erotica' }
    has_hentai = genres.any? { |genre| genre[:name] == 'Hentai' }

    to_exclude_erotica = false
    to_exclude_hentai = false

    genres
      .map do |genre|
        case genre[:name]
          when 'Award Winning' then next
          when 'Suspense' then genre[:name] = 'Thriller'
          when 'Avant Garde' then genre[:name] = 'Dementia'
          when 'Boys Love'
            if has_erotica || has_hentai
              replace_genre genre, 'Yaoi'
              to_exclude_erotica = true if has_erotica
              to_exclude_hentai = true if has_hentai
            else
              replace_genre genre, 'Shounen Ai'
            end
          when 'Girls Love'
            if has_erotica || has_hentai
              replace_genre genre, 'Yuri'
              to_exclude_erotica = true if has_erotica
              to_exclude_hentai = true if has_hentai
            else
              replace_genre genre, 'Shoujo Ai'
            end
        end

        genre
      end
      .compact
      .reject do |genre|
        (to_exclude_erotica && genre[:name] == 'Erotica') ||
          (to_exclude_hentai && genre[:name] == 'Hentai')
      end
  end

  def genres_repository
    AnimeGenresRepository.instance
  end

  def replace_genre genre, name
    genre[:name] = name
    genre[:id] = genres_repository.find { |v| v.name == name }.mal_id
  end

  # def schedule_fetch_authorized
  #   MalParsers::FetchEntryAuthorized.perform_async(
  #     entry.mal_id,
  #     entry.class.name
  #   )
  # end
end
