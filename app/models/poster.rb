class Poster < ApplicationRecord
  IS_ALLOW_MODERATABLE_REJECTED_TO_CANCEL = true # must be before ModeratableConcern
  IS_ALLOW_MODERATABLE_CENSORED = true
  include ModeratableConcern
  include Uploaders::PosterUploader::Attachment(:image)

  belongs_to :anime, optional: true, touch: true
  belongs_to :manga, optional: true, touch: true
  belongs_to :character, optional: true, touch: true
  belongs_to :person, optional: true, touch: true

  validates :anime_id, exclusive_arc: %i[manga_id character_id person_id]

  scope :active, -> { where is_approved: true, deleted_at: nil }

  WIDTH = 225

  def target
    anime || manga || character || person
  end

  def target_key
    if anime_id
      :anime_id
    elsif manga_id
      :manga_id
    elsif character_id
      :character_id
    elsif person_id
      :person_id
    end
  end

  def magnificable?
    (image_data&.dig('metadata', 'width') || 0) > WIDTH ||
      !!(image_data&.dig('metadata', 'width') && moderation_censored?)
  end

  def cropped?
    crop_data.present?
  end
end
