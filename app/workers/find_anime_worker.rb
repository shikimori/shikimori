class FindAnimeWorker
  include Sidekiq::Worker
  sidekiq_options unique: true,
                  unique_args: -> (args) { args },
                  retry: false

  def perform mode
    if mode == :full
      pages = parser.fetch_pages_num
      importer.import pages: 0..pages-1

    elsif mode == :first_page
      importer.import pages: [0], last_episodes: true

    elsif mode == :two_pages
      importer.import pages: [0, 1], last_episodes: true

    elsif mode == :last_3_entries
      ids = parser.fetch_page_links(0).take(3)
      importer.import ids: ids, last_episodes: true

    elsif mode == :last_15_entries
      ids = parser.fetch_page_links(0).take(15)
      importer.import ids: ids, last_episodes: true
    end
  end

  def importer
    self.class.name.sub(/Worker$/, 'Importer').constantize.new
  end

  def parser
    self.class.name.sub(/Worker$/, 'Parser').constantize.new
  end
end
