class AddDisplayImagesToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :display_images, :boolean, default: true
  end

  def self.down
    remove_column :groups, :display_images
  end
end
