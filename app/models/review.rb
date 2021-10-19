class Review < ApplicationRecord
  include AntispamConcern
  include Commentable
  include Moderatable
  include Viewable

  antispam(
    per_day: 15,
    disable_if: -> { Rails.env.development? && user&.admin? },
    user_id_key: :user_id
  )

  acts_as_votable cacheable_strategy: :update_columns

  belongs_to :user,
    touch: Rails.env.test? ? false : :activity_at
  belongs_to :anime, optional: true
  belongs_to :manga, optional: true

  has_many :abuse_requests, -> { order :id },
    dependent: :destroy,
    inverse_of: :review
  has_many :bans, -> { order :id },
    inverse_of: :review

  enumerize :opinion, in: Types::Review::Opinion.values

  MIN_BODY_SIZE = 230

  validates :body,
    presence: true,
    length: { minimum: MIN_BODY_SIZE },
    unless: -> { @is_migration }
  validates :user_id,
    uniqueness: { scope: %i[anime_id] },
    if: :anime?
  validates :user_id,
    uniqueness: { scope: %i[manga_id] },
    if: :manga?

  validates :anime_id, exclusive_arc: %i[manga_id]

  scope :positive, -> { where opinion: Types::Review::Opinion[:positive] }
  scope :neutral, -> { where opinion: Types::Review::Opinion[:neutral] }
  scope :negative, -> { where opinion: Types::Review::Opinion[:negative] }

  before_create :fill_is_written_before_release,
    if: -> { is_written_before_release.nil? }

  def html_body
    BbCodes::Text.call body
  end

  def anime?
    anime_id.present?
  end

  def manga?
    manga_id.present?
  end

  def db_entry
    anime? ? anime : manga
  end

  def db_entry_id
    anime_id || manga_id
  end

  def db_entry_released_before?
    db_entry.released? &&
      (!db_entry.released_on || db_entry.released_on <= Time.zone.today)
  end

  def cache_key_with_version
    "#{super}/user/#{user.id}/#{user.rate_at.to_i}"
  end

  def written_before_release?
    is_written_before_release && (
      !db_entry.ongoing? || (
        !db_entry.aired_on || db_entry.aired_on > 1.year.ago
      )
    )
  end

  def user_rate
    @user_rate ||=
      if anime?
        UserRate.find_by user_id: user_id, target_type: 'Anime', target_id: anime_id
      else
        UserRate.find_by user_id: user_id, target_type: 'Manga', target_id: manga_id
      end
  end

private

  def fill_is_written_before_release
    self.is_written_before_release = !db_entry_released_before?
  end
end
