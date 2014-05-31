class MangaOnline::ReadMangaPagesImporter
  def initialize pages
    @pages = pages
  end

  def save
    return [] if @pages.blank?

    sync_pages = MangaPage.where('url in (?)', @pages.map(&:url))
    db_urls = sync_pages.map(&:url)
    @pages.select {|c| !db_urls.include?(c.url) }.each do |page|
      page.save(validate: false)
      sync_pages << page
    end
    sync_pages
  end
end
