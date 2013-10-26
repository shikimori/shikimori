class UserImage < ActiveRecord::Base
  belongs_to :user
  belongs_to :linked, polymorphic: true

  validates_attachment_presence :image
  validates_presence_of :user

  has_attached_file :image,
                    styles: {
                      original: ['1920x1920>', :jpg],
                      preview: ['700x320>', :jpg]
                    },
                    url: '/images/user_image/:style/:user_id/:id.:extension',
                    path: ':rails_root/public/images/user_image/:style/:user_id/:id.:extension'
end
