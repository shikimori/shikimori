class Coub::Entry < Dry::Struct
  attribute :permalink, Types::String
  attribute :image_template, Types::String
  attribute :recoubed_permalink, Types::String.optional

  attribute :categories, Types::Array.of(Types::String)
  attribute :tags, Types::Array.of(Types::String)

  attribute :title, Types::String
  attribute :author, Coub::Author
  attribute :created_at, Types::DateTime

  VIEW_TEMPLATE = 'https://coub.com/view/%<permalink>s'
  EMBED_TEMPLATE = 'https://coub.com/embed/%<permalink>s?autostart=true&startWithHD=true'
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

  def url
    format VIEW_TEMPLATE, permalink: permalink
  end

  def player_url
    format EMBED_TEMPLATE, permalink: permalink
  end

  def image_url
    image_template.gsub(VERSION_TEMPALTE, 'med')
  end

  def image_2x_url
    image_template.gsub(VERSION_TEMPALTE, 'big')
  end
end
