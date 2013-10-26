class AddShowStatisticsToProfileSettings < ActiveRecord::Migration
  def self.up
    add_column :profile_settings, :statistics, :boolean, default: true
  end

  def self.down
    remove_column :profile_settings, :statistics
  end
end
