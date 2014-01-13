class FindAnimeJob < Struct.new(:mode)
  def perform
    if mode == :full
      pages = FindAnimeParser.new.fetch_pages_num
      FindAnimeImporter.new.import pages: 0..pages-1

    elsif mode == :first_page
      FindAnimeImporter.new.import pages: [0], last_episodes: true

    elsif mode == :last_3_entries
      ids = FindAnimeParser.new.fetch_page_links(0).take(3)
      FindAnimeImporter.new.import ids: ids, last_episodes: true

    elsif mode == :last_15_entries
      ids = FindAnimeParser.new.fetch_page_links(0).take(15)
      FindAnimeImporter.new.import ids: ids, last_episodes: true
    end
  end
end
