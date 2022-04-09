class WebmVideo < ApplicationRecord
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

  # state_machine :state, initial: :pending do
  #   state :pending
  #   state :processed
  #   state :failed
  # 
  #   event(:process) { transition %i[pending processed failed] => :processed }
  #   event(:to_failed) { transition %i[pending processed failed] => :failed }
  # end

  def schedule_thumbnail
    WebmThumbnail.perform_async id
  end
end
