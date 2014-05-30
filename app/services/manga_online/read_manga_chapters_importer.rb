class MangaOnline::ReadMangaChaptersImporter
  def initialize chapters
    @chapters = chapters
  end

  def save
    return [] if @chapters.blank?

    sync_chapters = MangaChapter.where('url in (?)', @chapters.map(&:url))
    db_urls = sync_chapters.map(&:url)
    @chapters.select {|c| !db_urls.include?(c.url) }.each do |chapter|
      chapter.save(validate: false)
      sync_chapters << chapter
    end
    sync_chapters
  end
end
