class Coub::Entry < Dry::Struct
  attribute :player_url, Types::String
  attribute :image_url, Types::String
  attribute :categories, Types::Array.of(Types::String)
  attribute :tags, Types::Array.of(Types::String)

  def anime?
    categories.none? ||
      categories.include?('anime') ||
      tags.include?('anime') ||
      tags.include?('аниме')
  end
end
