class AnimesCollection::Page
  include ShallowAttributes

  attribute :collection, Array, of: ApplicationRecord
  attribute :page, Integer
  attribute :pages_count, Integer

  # for correct shallow attributes conversion
  attr_writer :collection

  def next_page
    page + 1 if page < pages_count
  end

  def prev_page
    page - 1 if page > 1
  end
end
