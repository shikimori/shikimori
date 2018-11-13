class FindAnimeWorker
  include Sidekiq::Worker
  sidekiq_options(
    queue: :anime_online_parsers,
    retry: false
  )

  def perform mode
    case mode.to_sym
      when :full
        pages = parser.fetch_pages_num
        importer.import pages: 0..pages-1

      when :first_page
        importer.import pages: [0], last_episodes: true

      when :two_pages
        importer.import pages: [0, 1], last_episodes: true

      when :last_3_entries
        ids = parser.fetch_page_links(0).take(3)
        importer.import ids: ids, last_episodes: true

      when :last_15_entries
        ids = parser.fetch_page_links(0).take(15)
        importer.import ids: ids, last_episodes: true

      else raise "unknown mode: #{mode}"
    end
  end

  def importer
    self.class.name.sub(/Worker$/, 'Importer').constantize.new
  end

  def parser
    self.class.name.sub(/Worker$/, 'Parser').constantize.new
  end
end
