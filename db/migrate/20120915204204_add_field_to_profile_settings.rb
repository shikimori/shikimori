class AddFieldToProfileSettings < ActiveRecord::Migration
  def self.up
    add_column :profile_settings, :statistics_start, :date
  end

  def self.down
    remove_column :profile_settings, :statistics_start
  end
end
