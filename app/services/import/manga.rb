class Import::Manga < Import::Anime
  SPECIAL_FIELDS = Import::Anime::SPECIAL_FIELDS + %i(publishers) - %i(
    studios external_links
  )

private

  def assign_publishers publishers
    publishers.each do |publisher|
      db_publisher = Repos::Publishers.instance.all.find do |db_entry|
        db_entry.id == publisher[:id]
      end
      db_publisher ||= Publisher.create!(
        id: publisher[:id],
        name: publisher[:name]
      )
      entry.publishers << db_publisher
    end
  end

  def genres_repo
    Repos::MangaGenres.instance
  end
end
