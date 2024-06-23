class DbImport::Anime < DbImport::ImportBase # rubocop:disable Metrics/ClassLength
  SPECIAL_FIELDS = %i[
    image synopsis
    genres studios related recommendations characters
    external_links
  ]
  IGNORED_FIELDS = DbImport::ImportBase::IGNORED_FIELDS + %i[members favorites]
  LGBT_GENRES = {
    yaoi: 'Boys Love',
    yuri: 'Girls Love'
  }
  CENSORED_GENRES = %w[
    Hentai
    Erotica
  ]

private

  def assign_synopsis synopsis
    super unless anidb_synopsis? && entry.description_en.present?
  end

  def assign_genres genres
    unless :genre_v2_ids.in? desynced_fields
      entry.genre_v2_ids = remap_genres(genres).map { |v| import_genre(v).id }
    end
  end

  def import_genre data # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    return data if data.is_a? GenreV2

    genre = data[:id] ?
      genres_repository.by_mal_id(data[:id]) :
      genres_repository.by_name(data[:name])
    raise ArgumentError, "mismatched genre: #{data.to_json}" unless genre.name == data[:name]

    genre
  rescue ActiveRecord::RecordNotFound
    entry_type = self.class.name.split('::').last

    GenreV2.create!(
      id: Genre.find_by(kind: entry_type.downcase, name: data[:name])&.id,
      mal_id: data[:id],
      name: data[:name],
      russian: data[:name],
      kind: data[:kind],
      entry_type:,
      description: ''
    )
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

  def assign_characters data
    if data[:characters].any? || data[:staff].any?
      DbImport::PersonRoles.call entry, data[:characters], data[:staff]
    end
  end

  def assign_external_links external_links
    DbImport::ExternalLinks.call entry, external_links
  end

  def anidb_synopsis?
    entry.all_external_links.any? do |external_link|
      external_link.kind_anime_db? && external_link.imported_at.present?
    end
  end

  # def preprocess_genres genres
  #   has_erotica = genres.any? { |genre| genre[:name] == 'Erotica' }
  #   has_hentai = genres.any? { |genre| genre[:name] == 'Hentai' }
  #
  #   to_exclude_erotica = false
  #   to_exclude_hentai = false
  #
  #   genres
  #     .map do |genre|
  #       case genre[:name]
  #         when 'Award Winning' then next
  #         when 'Suspense' then genre[:name] = 'Thriller'
  #         when 'Avant Garde' then genre[:name] = 'Dementia'
  #         when 'Boys Love'
  #           if has_erotica || has_hentai
  #             replace_genre genre, 'Yaoi'
  #             to_exclude_erotica = true if has_erotica
  #             to_exclude_hentai = true if has_hentai
  #           else
  #             replace_genre genre, 'Shounen Ai'
  #           end
  #         when 'Girls Love'
  #           if has_erotica || has_hentai
  #             replace_genre genre, 'Yuri'
  #             to_exclude_erotica = true if has_erotica
  #             to_exclude_hentai = true if has_hentai
  #           else
  #             replace_genre genre, 'Shoujo Ai'
  #           end
  #       end
  #
  #       genre
  #     end
  #     .compact
  #     .reject do |genre|
  #       (to_exclude_erotica && genre[:name] == 'Erotica') ||
  #         (to_exclude_hentai && genre[:name] == 'Hentai')
  #     end
  # end

  def genres_repository
    AnimeGenresV2Repository.instance
  end

  # def replace_genre genre, name
  #   genre[:name] = name
  #   genre[:id] = genres_repository.find { |v| v.name == name }.mal_id
  # end

  # def schedule_fetch_authorized
  #   MalParsers::FetchEntryAuthorized.perform_async(
  #     entry.mal_id,
  #     entry.class.name
  #   )
  # end

  def import_more_info
    return unless entry.more_info.nil?

    more_info = MalParser::Entry::MoreInfo.call entry.id, entry.anime? ? :anime : :manga
    entry.update more_info:
  end

  def remap_genres genres # rubocop:disable all
    if genres.any? { |v| v[:name].in?(CENSORED_GENRES) }
      cleaned_genres = genres.reject do |v|
        v[:name].in?(LGBT_GENRES.values) || v[:name].in?(CENSORED_GENRES)
      end

      if genres.any? { |v| v[:name] == LGBT_GENRES[:yaoi] }
        return cleaned_genres + [genres_repository.by_name('Yaoi')]
      elsif genres.any? { |v| v[:name] == LGBT_GENRES[:yuri] }
        return cleaned_genres + [genres_repository.by_name('Yuri')]
      end
    end

    genres
  end
end
