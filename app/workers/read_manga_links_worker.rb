class ReadMangaLinksWorker
  include Sidekiq::Worker
  sidekiq_options unique: :until_executed

  def perform
    Manga
      .where("description_ru ilike '%readmanga%'")
      .find_each do |manga|
        next unless manga.decorate.description_ru.source
        id = "rm_#{manga.decorate.description_ru.source.sub /^.*\//, ''}"
        manga.update_column(:read_manga_id, id) if id != manga.read_manga_id
      end

    Manga
      .where("description_ru ilike '%adultmanga%'")
      .find_each do |manga|
        next unless manga.decorate.description_ru.source
        id = "am_#{manga.decorate.description_ru.source.sub /^.*\//, ''}"
        manga.update_column(:read_manga_id, id) if id != manga.read_manga_id
      end
  end
end
