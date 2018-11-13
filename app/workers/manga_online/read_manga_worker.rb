class MangaOnline::ReadMangaWorker
  include Sidekiq::Worker
  sidekiq_options(
    queue: :manga_online_parsers,
    retry: false
  )

  def perform
    mangas_for_import.each do |manga|
      process(manga)
    end
  end

private

  def mangas_for_import
    # NOTE: Лимит оставил, чтобы проверить сначала все ли правильно загрузилось на продакшене.
    Manga
      .where('read_manga_id is not null')
      .where(parsed_at: nil)
      .limit(10)
  end

  def process manga
    MangaOnline::ReadMangaService.new(manga, true).process
  end
end
