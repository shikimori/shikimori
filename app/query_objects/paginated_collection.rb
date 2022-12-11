class PaginatedCollection < SimpleDelegator
  attr_reader :page, :limit

  def initialize collection, page, limit
    super collection
    @page = page
    @limit = limit
  end

  def next_page
    page + 1 if next_page?
  end

  def next_page?
    size == limit
  end

  def prev_page
    page - 1 if prev_page?
  end

  def prev_page?
    page > 1
  end
end
