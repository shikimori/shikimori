class AnimesCollection::Page < Dry::Struct
  attribute :collection, Types::Strict::Array
  attribute :page, Types::Coercible::Integer
  attribute :pages_count, Types::Coercible::Integer

  def next_page
    page + 1 if page < pages_count
  end

  def prev_page
    page - 1 if page > 1
  end
end
