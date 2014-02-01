class Cosplayer < ActiveRecord::Base
  has_many :cosplay_gallery_links, as: :linked, dependent: :destroy
  has_many :cosplay_galleries, -> { where deleted: false },
    through: :cosplay_gallery_links,
    class_name: 'CosplaySession'

  def to_param
    "%d-%s" % [id, name.gsub(' ', '-').gsub(/^-|-$/, '')]
  end
end
