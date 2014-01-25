class UserImage < ActiveRecord::Base
  belongs_to :user
  belongs_to :linked, polymorphic: true

  validates_attachment_presence :image
  validates_presence_of :user

  has_attached_file :image,
    styles: {
      original: ['1920x1920>', :jpg],
      preview: ['700x320>', :jpg],
      thumbnail: ['150x150>', :jpg]
    },
    url: '/images/user_image/:style/:user_id/:id.:extension',
    path: ':rails_root/public/images/user_image/:style/:user_id/:id.:extension'

  before_create :set_dimentions

private
  def set_dimentions
    geometry = Paperclip::Geometry.from_file image.queued_for_write[:original] || image.path
    self.width = geometry.width.to_i
    self.height = geometry.height.to_i
    save! if persisted?
  end
end
