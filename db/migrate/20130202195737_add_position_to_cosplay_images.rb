class AddPositionToCosplayImages < ActiveRecord::Migration
  def self.up
    add_column :cosplay_images, :position, :integer
  end

  def self.down
    remove_column :cosplay_images, :position
  end
end
