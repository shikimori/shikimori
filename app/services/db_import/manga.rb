class DbImport::Manga < DbImport::Anime
  SPECIAL_FIELDS = DbImport::Anime::SPECIAL_FIELDS + %i[publishers] - %i[
    studios
  ]

private

  def find_or_create_genre data
    MangaGenresRepository.instance.find_by_mal_id data[:id]
  rescue ActiveRecord::RecordNotFound
    Genre.create! mal_id: data[:id], name: data[:name], kind: :manga
  end

  def assign_publishers publishers
    entry.publisher_ids = publishers.map { |v| find_or_create_publisher(v).id }
  end

  def find_or_create_publisher data
    publisher = PublishersRepository.instance.find data[:id]

    if publisher.name != data[:name] && !publisher.desynced.include?('name')
      publisher.update! name: data[:name]
    end

    publisher
  rescue ActiveRecord::RecordNotFound
    Publisher.create! id: data[:id], name: data[:name]
  end
end
