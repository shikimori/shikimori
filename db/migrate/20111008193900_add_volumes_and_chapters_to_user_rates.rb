class AddVolumesAndChaptersToUserRates < ActiveRecord::Migration
  def self.up
    add_column :user_rates, :volumes, :integer, :default => 0, :null => false
    add_column :user_rates, :chapters, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :user_rates, :chapters
    remove_column :user_rates, :volumes
  end
end
