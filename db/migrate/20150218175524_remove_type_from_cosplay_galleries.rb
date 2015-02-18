class RemoveTypeFromCosplayGalleries < ActiveRecord::Migration
  def change
    remove_column :cosplay_galleries, :type
  end
end
