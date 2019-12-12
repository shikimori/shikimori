class MalParsers::FetchPage
  include Sidekiq::Worker
  sidekiq_options(
    queue: :mal_parsers,
    retry: false
  )

  TYPES = Types::Strict::String.enum('anime', 'manga')
  REFRESH_INTERVAL = 8.hours

  def perform type, sorting, page, max_pages
    entries = MalParser::Catalog::Page.call(
      type: TYPES[type],
      page: page,
      sorting: sorting
    )

    entries.each { |entry| schedule_entry entry }
    refresh type, entries

    unless finished? entries.size, page, max_pages
      schedule_page type, sorting, page + 1, max_pages
    end
  end

private

  def finished? entries_count, page, max_pages
    entries_count != MalParser::Catalog::Page::ENTRIES_PER_PAGE ||
      page >= max_pages
  end

  def schedule_entry entry
    MalParsers::FetchEntry.perform_async entry[:id], entry[:type]
  end

  def schedule_page type, sorting, page, max_pages
    MalParsers::FetchPage.perform_async(
      type,
      sorting,
      page,
      max_pages
    )
  end

  def refresh type, entries
    DbImport::Refresh.call(
      type.classify.constantize,
      entries.map { |entry| entry[:id] },
      REFRESH_INTERVAL
    )
  end
end
