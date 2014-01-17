class AdultMangaWorker
  include Sidekiq::Worker
  sidekiq_options unique: true, retry: 1

  def perform
    ReadMangaImporter.new.import pages: 0..1
  end
end
