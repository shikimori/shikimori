class CosplayImage < ApplicationRecord
  PositionStep = 10

  belongs_to :gallery,
    class_name: CosplayGallery.name,
    foreign_key: :cosplay_gallery_id

  has_attached_file :image,
    styles: { preview: "178x534>" },
    url: "/system/cosplay_images/:style/:id.:extension",
    path: ":rails_root/public/system/cosplay_images/:style/:id.:extension",
    default_url: '/assets/globals/missing_:style.jpg'

  validates :image, attachment_content_type: { content_type: /\Aimage/ }
end
