class ReadMangaWorker
  include Sidekiq::Worker
  sidekiq_options(
    queue: :manga_online_parsers,
    retry: 1
  )

  def perform
    ReadMangaImporter.new.import pages: 0..1
  end
end
