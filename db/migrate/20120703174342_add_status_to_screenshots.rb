class AddStatusToScreenshots < ActiveRecord::Migration
  def self.up
    add_column :screenshots, :status, :string
  end

  def self.down
    remove_column :screenshots, :status
  end
end
