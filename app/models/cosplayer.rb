class Cosplayer < ApplicationRecord
  has_many :cosplay_gallery_links, as: :linked, dependent: :destroy
  has_many :cosplay_galleries, -> { where deleted: false },
    through: :cosplay_gallery_links

  def to_param
    "%d-%s" % [id, name.gsub(' ', '-').gsub(/^-|-$/, '')]
  end
end
