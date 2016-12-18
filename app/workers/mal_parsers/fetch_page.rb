class MalParsers::FetchPage
  include Sidekiq::Worker
  sidekiq_options(
    unique: :until_executed,
    queue: :mal_parsers
  )

  def perform type, page, sorting, max_pages
    entries = MalParser::Catalog::Page.call(
      type: type,
      page: page,
      sorting: sorting
    )

    entries.each { |entry| schedule_entry entry }

    unless finished? entries.size, page, max_pages
      schedule_page type, page + 1, sorting, max_pages
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

  def schedule_page type, page, sorting, max_pages
    MalParsers::FetchPage.perform_async(
      type,
      page,
      sorting,
      max_pages
    )
  end
end
