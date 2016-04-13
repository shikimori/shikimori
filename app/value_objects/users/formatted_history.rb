class Users::FormattedHistory < ViewObjectBase
  include Virtus.model

  attribute :name, String
  attribute :russian, String
  attribute :image, String
  attribute :image_2x, String
  attribute :action, String
  attribute :created_at, ActiveSupport::TimeWithZone
  attribute :url, String

  attribute :action_info, String

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
