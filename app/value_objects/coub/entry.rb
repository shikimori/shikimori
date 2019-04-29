class Coub::Entry
  include ShallowAttributes

  attribute :permalink, String
  attribute :image_template, String
  attribute :recoubed_permalink, String, allow_nil: true

  attribute :categories, Array, of: String
  attribute :tags, Array, of: String

  attribute :title, String
  attribute :author, Coub::Author
  attribute :created_at, ActiveSupport::TimeWithZone

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

  def recoubed?
    recoubed_permalink.present?
  end

  def original_url
    return unless recoubed?

    format VIEW_TEMPLATE, permalink: recoubed_permalink
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
