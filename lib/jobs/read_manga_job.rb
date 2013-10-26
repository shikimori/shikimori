class ReadMangaJob
  def perform
    ReadMangaImporter.new.import pages: 0..1
    AdultMangaImporter.new.import pages: 0..1
  end
end
