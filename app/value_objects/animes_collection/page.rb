class AnimesCollection::Page
  include Virtus.model

  attribute :collection

  attribute :page, Integer
  attribute :pages_count, Integer

  def next_page
    page + 1 if page < pages_count
  end

  def prev_page
    page - 1 if page > 1
  end
end
