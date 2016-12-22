class AnimesCollection::Page < Dry::Struct
  constructor_type(:schema)

  attribute :collection, Types::Strict::Array
  attribute :page, Types::Coercible::Int
  attribute :pages_count, Types::Coercible::Int

  def next_page
    page + 1 if page < pages_count
  end

  def prev_page
    page - 1 if page > 1
  end
end
