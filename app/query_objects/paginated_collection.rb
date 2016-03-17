class PaginatedCollection < SimpleDelegator
  WINDOW = 4

  attr_reader :current_page
  attr_reader :limit

  def initialize collection, page, limit
    super collection
    @current_page = page
    @limit = limit
  end

  def next_page
    current_page + 1 if size == limit
  end

  def prev_page
    current_page - 1 if current_page > 1
  end
end
