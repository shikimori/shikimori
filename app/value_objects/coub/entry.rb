class Coub::Entry < Dry::Struct
  attribute :permalink, Types::String
  attribute :image_template, Types::String
  attribute :recoubed_permalink, Types::String.optional

  attribute :categories, Types::Array.of(Types::String)
  attribute :tags, Types::Array.of(Types::String)

  attribute :title, Types::String
  attribute :author, Coub::Author

  VERSION_TEMPALTE = '%{version}' # rubocop:disable FormatStringToken
  # micro
  # tiny
  # age_restricted
  # ios_large
  # ios_mosaic
  # big
  # med
  # small
  # pinterest

  def anime?
    categories.none? ||
      categories.include?('anime') ||
      tags.include?('anime') ||
      tags.include?('аниме')
  end

  def image_url
    image_template.gsub(VERSION_TEMPALTE, 'big')
  end
end
