class ClubImage < ApplicationRecord
  belongs_to :club, touch: true
  belongs_to :user

  has_attached_file :image,
    styles: {
      original: '1920x1200>',
      preview: '178x534>'
    },
    url: '/system/images/:style/:id.:extension',
    path: ':rails_root/public/system/images/:style/:id.:extension'

  validates :image,
    attachment_presence: true,
    attachment_content_type: { content_type: /\Aimage/ }
  validates :club, :user, presence: true

  def to_param
    "#{id}-#{updated_at.to_i}"
  end
end
