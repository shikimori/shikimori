class DbImport::Manga < DbImport::Anime
  SPECIAL_FIELDS = DbImport::Anime::SPECIAL_FIELDS + %i[publishers] - %i[
    studios
  ]

private

  def assign_is_censored
    return if :is_censored.in? desynced_fields

    entry.is_censored = entry.kind_doujin? || entry.genres.any?(&:censored?)
  end

  def assign_publishers publishers
    entry.publisher_ids = publishers.map { |v| find_or_create_publisher(v).id }
  end

  def find_or_create_publisher data
    publisher = PublishersRepository.instance.find data[:id]

    if publisher.name != data[:name] && publisher.desynced.exclude?('name')
      publisher.update! name: data[:name]
    end

    publisher
  rescue ActiveRecord::RecordNotFound
    Publisher.create! id: data[:id], name: data[:name]
  end

  def genres_repository
    MangaGenresRepository.instance
  end
end
