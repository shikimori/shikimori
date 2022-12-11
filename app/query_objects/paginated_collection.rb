class PaginatedCollection < SimpleDelegator
  attr_reader :page, :limit, :collection_size

  def initialize collection, page, limit, collection_size = nil
    super collection
    @page = page
    @limit = limit
    @collection_size = collection_size
  end

  def next_page
    page + 1 if next_page?
  end

  def next_page?
    (@collection_size || size) == limit
  end

  def prev_page
    page - 1 if prev_page?
  end

  def prev_page?
    page > 1
  end
end
