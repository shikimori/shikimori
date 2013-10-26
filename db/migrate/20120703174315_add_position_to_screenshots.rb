class AddPositionToScreenshots < ActiveRecord::Migration
  def self.up
    add_column :screenshots, :position, :integer, :null => false
  end

  def self.down
    remove_column :screenshots, :position
  end
end
