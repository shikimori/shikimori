class UserImage < ActiveRecord::Base
  belongs_to :user
  belongs_to :linked, polymorphic: true

  has_attached_file :image,
    styles: {
      original: ['1920x1920>', :jpg],
      preview: ['700x700>', :jpg],
      thumbnail: ['235x235>', :jpg]
    },
    url: '/images/user_image/:style/:user_id/:id.:extension',
    path: ':rails_root/public/images/user_image/:style/:user_id/:id.:extension'

  validates :user, presence: true
  validates :image, attachment_presence: true, attachment_content_type: { content_type: /\Aimage/ }

  before_create :set_dimentions

private

  def set_dimentions
    geometry = Paperclip::Geometry.from_file image.queued_for_write[:original] || image.path
    self.width = geometry.width.to_i
    self.height = geometry.height.to_i
    save! if persisted?
  end
end
