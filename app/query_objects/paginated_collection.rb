class PaginatedCollection < SimpleDelegator
  WINDOW = 4

  attr_reader :page
  attr_reader :limit

  def initialize collection, page, limit
    super collection
    @page = page
    @limit = limit
  end

  def next_page
    page + 1 if size == limit
  end

  def prev_page
    page - 1 if page > 1
  end
end
