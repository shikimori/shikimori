class RemoveDateFromCosplayGalleries < ActiveRecord::Migration
  def up
    CosplayGallery.connection.execute('update cosplay_galleries set created_at=date, updated_at=date')
    remove_column :cosplay_galleries, :date
  end

  def down
    add_column :cosplay_galleries, :date, :date
    CosplayGallery.connection.execute('update cosplay_galleries set date=created_at')
  end
end
