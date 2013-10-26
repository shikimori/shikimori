class AddDeletedToCosplayImage < ActiveRecord::Migration
  def self.up
    add_column :cosplay_images, :deleted, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :cosplay_images, :deleted, :null => false, :default => false
  end
end
