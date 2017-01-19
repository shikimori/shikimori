class Image < ActiveRecord::Base
  belongs_to :uploader, class_name: User.name, foreign_key: :uploader_id
  belongs_to :owner, polymorphic: true, touch: true

  has_attached_file :image,
    styles: {
      main: '1920x1200>',
      preview: '178x534>'
    },
    url: '/system/images/:style/:id.:extension',
    path: ':rails_root/public/system/images/:style/:id.:extension'

  validates :image,
    attachment_presence: true,
    attachment_content_type: { content_type: /\Aimage/ }
  validates :uploader, :owner, presence: true

  def to_param
    "#{id}-#{updated_at.to_i}"
  end
end
