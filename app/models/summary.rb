class Summary < ApplicationRecord
  include AntispamConcern
  include Moderatable
  include Viewable

  antispam(
    interval: 1.minute,
    disable_if: -> { Rails.env.development? && user&.admin? },
    user_id_key: :user_id
  )

  belongs_to :user
  belongs_to :anime, optional: true
  belongs_to :manga, optional: true

  enumerize :tone, in: Types::Summary::Tone.values

  validates :body, presence: true
  validates :user_id,
    uniqueness: { scope: %i[anime_id] },
    if: :anime?
  validates :user_id,
    uniqueness: { scope: %i[manga_id] },
    if: :manga?

  validates :anime, presence: true, unless: :manga?
  validates :manga, presence: true, unless: :anime?

  def html_body
    BbCodes::Text.call body
  end

  def anime?
    anime_id.present?
  end

  def manga?
    manga_id.present?
  end
end
