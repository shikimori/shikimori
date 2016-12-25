class Users::FormattedHistory < Dry::Struct
  include Draper::ViewHelpers

  constructor_type(:schema)

  attribute :name, Types::Strict::String
  attribute :russian, Types::Strict::String.optional
  attribute :image, Types::Strict::String
  attribute :image_2x, Types::Strict::String
  attribute :action, Types::Strict::String
  attribute :created_at, Types::DateTime
  attribute :url, Types::Strict::String
  attribute :action_info, Types::Strict::String.optional

  def localized_name
    h.localization_span self
  end

  def reversed_action
    action
      .split(/(?<!\d[йяюо]), (?!\d)/)
      .reverse
      .join(', ')
      .gsub(/<.*?>/, '')
  end

  def special?
    action_info.present?
  end

  def iso_date
    created_at.iso8601
  end

  def localized_date
    h.l(created_at, format: '%e %B %Y').strip
  end
end
