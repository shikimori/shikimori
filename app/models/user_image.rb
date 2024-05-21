class UserImage < ApplicationRecord
  belongs_to :user
  belongs_to :linked, polymorphic: true, optional: true

  has_attached_file :image,
    styles: {
      original: ['1920x1920>', :jpg],
      preview: ['700x700>', :jpg],
      thumbnail: ['235x235>', :jpg]
    },
    url: '/system/user_images/:style/:user_id/:hash.:extension',
    path: ':rails_root/public/system/user_images/:style/:user_id/:hash.:extension'

  validates :image,
    attachment_presence: true,
    attachment_content_type: { content_type: /\Aimage/ }

  before_create :set_dimentions

  Paperclip.interpolates :hash do |attachment, _style|
    attachment.instance.generate_image_hash
  end

  def generate_image_hash
    return id if id <= 2_608_297

    secret_key = Rails.application.secrets.secret_key_base

    Digest::SHA256.hexdigest("#{id}-#{secret_key}")
  end

private

  def set_dimentions
    geometry =
      Paperclip::Geometry.from_file image.queued_for_write[:original] ||
      image.path
    self.width = geometry.width.to_i
    self.height = geometry.height.to_i
    save! if persisted?
  end
end
