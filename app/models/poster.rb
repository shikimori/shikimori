class Poster < ApplicationRecord
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

  def magnificable?
    (image_data&.dig('metadata', 'width') || 0) > WIDTH
  end
end
