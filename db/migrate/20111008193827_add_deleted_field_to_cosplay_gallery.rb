class AddDeletedFieldToCosplayGallery < ActiveRecord::Migration
  def self.up
    add_column :cosplay_galleries, :deleted, :boolean, :null => false, :default => false
    change_column :cosplay_galleries, :confirmed, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :cosplay_galleries, :deleted
  end
end
