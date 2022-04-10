class WebmVideo < ApplicationRecord
  include AASM

  has_attached_file :thumbnail,
    styles: {
      normal: ['235x132#', :jpg],
      retina: ['470x264#', :jpg]
    },
    url: '/system/webm_videos/:style/:id.:extension',
    path: ':rails_root/public/system/webm_videos/:style/:id.:extension',
    default_url: '/system/webm_videos/:style/:id.:extension'

  validates :url, presence: true, uniqueness: true
  validates :thumbnail, attachment_content_type: { content_type: /\Aimage/ }

  after_create :schedule_thumbnail

  aasm column: 'state' do
    state :pending, initial: true
    state :processed
    state :failed

    event :process do
      transitions from: %i[pending failed], to: :processed
    end
    event :to_failed do
      transitions from: %i[pending processed], to: :failed
    end
  end

private

  def schedule_thumbnail
    WebmThumbnail.perform_async id
  end
end
