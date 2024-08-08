class UserImage < ApplicationRecord
  belongs_to :user
  belongs_to :linked, polymorphic: true, optional: true

  has_attached_file :image,
    styles: {
      original: ['1920x1920>', :jpg],
      preview: ['700x700>', :jpg],
      thumbnail: ['235x235>', :jpg]
    },
    convert_options: { all: '-strip' },
    url: '/system/:folder_name/:style/:user_id_hash/:id_hash.:extension',
    path: ':rails_root/public/system/:folder_name/:style/:user_id_hash/:id_hash.:extension'

  validates :image,
    attachment_presence: true,
    attachment_content_type: { content_type: /\Aimage/ }

  before_create :set_dimentions

  Paperclip.interpolates :folder_name do |attachment, _style|
    attachment.instance.generate_folder_name
  end
  Paperclip.interpolates :user_id_hash do |attachment, _style|
    attachment.instance.generate_user_id_hash
  end
  Paperclip.interpolates :id_hash do |attachment, _style|
    attachment.instance.generate_image_id_hash
  end

  FIRST_FIX_IMAGE_ID = 2_608_298
  SECOND_FIX_IMAGE_ID = 2_608_595

  def generate_folder_name
    if id >= SECOND_FIX_IMAGE_ID || is_hashed
      'user_images_h'
    else
      'user_images'
    end
  end

  def generate_user_id_hash
    if id >= SECOND_FIX_IMAGE_ID || is_hashed
      Digest::SHA256.hexdigest(
        "#{user_id}-#{Rails.application.secrets.secret_key_base}"
      )[0..23]
    else
      user_id
    end
  end

  def generate_image_id_hash
    if id >= FIRST_FIX_IMAGE_ID || is_hashed
      Digest::SHA256.hexdigest(
        "#{id}-#{Rails.application.secrets.secret_key_base}"
      )
    else
      id
    end
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
