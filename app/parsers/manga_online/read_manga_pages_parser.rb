class MangaOnline::ReadMangaPagesParser < SiteParserWithCache
  def initialize chapter, no_proxy=false
    @chapter = chapter
    @no_proxy = no_proxy
  end

  def pages
    pages = []
    doc = Nokogiri::HTML(get @chapter.url)
    urls = doc.css('script').text.scan(/var pictures = \[(.*)\]/).flatten.first.scan(/url:.*?"(.*?)"/)
    urls.each_with_index do |url, index|
      pages << MangaPage.new(chapter: @chapter, url: url.first, number: index + 1)
    end
    pages
  end
end
