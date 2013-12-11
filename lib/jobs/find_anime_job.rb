class FindAnimeJob < Struct.new(:full_import)
  def perform
    if full_import
      pages = FindAnimeParser.new.fetch_pages_num
      FindAnimeImporter.new.import pages: 0..pages-1, full: true
    else
      FindAnimeImporter.new.import pages: [0], full: false
    end
  end
end
