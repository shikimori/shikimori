class AddSourceToCosplayGallery < ActiveRecord::Migration
  def self.up
    add_column :cosplay_galleries, :source, :string
    ActiveRecord::Base.connection.
                       execute("update cosplay_galleries set source='%s' where source is null" % CosplayGallerySource::CosRain)
  end

  def self.down
    remove_column :cosplay_galleries, :source
  end
end
