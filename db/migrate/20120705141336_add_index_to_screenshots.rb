class AddIndexToScreenshots < ActiveRecord::Migration
  def self.up
    add_index :screenshots, :status
  end

  def self.down
    remove_index :screenshots, :status
  end
end
