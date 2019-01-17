class Coub::Entry < Dry::Struct
  attribute :permalink, Types::String
  attribute :image_url, Types::String

  attribute :categories, Types::Array.of(Types::String)
  attribute :tags, Types::Array.of(Types::String)

  attribute :title, Types::String
  attribute :author, Coub::Author

  def anime?
    categories.none? ||
      categories.include?('anime') ||
      tags.include?('anime') ||
      tags.include?('аниме')
  end
end
