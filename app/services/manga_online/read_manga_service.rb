class MangaOnline::ReadMangaService
  def initialize manga, no_proxy=false
    @manga = manga
    @no_proxy = no_proxy
  end

  def process
    print "Process manga: #{@manga.name} ------------------------------\n\n" unless Rails.env.test?
    source_id = @manga.read_manga_id.sub 'rm_', ''
    entry = ReadMangaParser.new.fetch_entry source_id
    chapters = MangaOnline::ReadMangaChaptersParser.new(@manga.id, entry[:read_first_url], @no_proxy).chapters

    print "Find #{chapters.count} chapters ----------------------------\n\n" unless Rails.env.test?
    db_chapters = MangaOnline::ReadMangaChaptersImporter.new(chapters).save

    db_chapters.each do |chapter|
      print "Process chapter: #{chapter.name} ------------------------------\n\n" unless Rails.env.test?
      pages = MangaOnline::ReadMangaPagesParser.new(chapter, @no_proxy).pages

      print "Find #{chapters.count} pages ----------------------------------\n\n" unless Rails.env.test?
      db_pages = MangaOnline::ReadMangaPagesImporter.new(pages).save
      db_pages.each do |page|
        unless page.image_file_name
          page.load_image
          #sleep 2 if Rails.env.development?
          sleep 1
        end
      end
    end
  end
end
