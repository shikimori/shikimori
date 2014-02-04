class AttachedImage < ActiveRecord::Base
  belongs_to :owner, polymorphic: true

  has_attached_file :image,
    styles: { preview: "178x534>" },
    url: "/images/attached_image/:style/:id.:extension",
    path: ":rails_root/public/images/attached_image/:style/:id.:extension"#,
    #default_url: '/anime_images/anime_:style_missing.png'

  validates :image, attachment_content_type: { content_type: /\Aimage/ }
  ##validates_attachment_presence :image
  #validates_presence_of :mal
  #validates_presence_of :anime_id
end
