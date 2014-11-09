class MangaOnline::ReadMangaWorker
  include Sidekiq::Worker
  sidekiq_options unique: true,
                  queue: :slow_parsers,
                  retry: false

  def perform
    mangas_for_import.each do |manga|
      MangaOnline::ReadMangaService.new(manga, true).process
    end
  end

private
  def mangas_for_import
    #NOTE: пока нет признака успешного завершения парсинга:
    Manga
      .where('read_manga_id like ?', 'rm_%')
      .limit(1)
      .select { |manga| manga.manga_chapters.blank? }
  end
end
