class AddClubsToProfileSettings < ActiveRecord::Migration
  def self.up
    add_column :profile_settings, :clubs, :boolean, default: true
  end

  def self.down
    remove_column :profile_settings, :clubs
  end
end
