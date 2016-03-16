class PaginatedCollection < SimpleDelegator
  WINDOW = 4

  attr_reader :current_page
  attr_reader :total_pages

  def initialize collection, current_page, total_pages
    super collection
    @current_page = current_page
    @total_pages = total_pages
  end

  def next_page
    current_page + 1 if current_page < total_pages
  end

  def prev_page
    current_page - 1 if current_page > 1
  end
end
