class FindAnimeJob < Struct.new(:full_import)
  def perform
    if full_import
      pages = FindAnimeParser.new.fetch_pages_num
      FindAnimeImporter.new.import pages, full_import
    else
      FindAnimeImporter.new.import 0, false
    end
  end
end
