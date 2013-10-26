class AddNotificationsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :notifications, :integer, :default => User::DEFAULT_NOTIFICATIONS
  end

  def self.down
    remove_column :users, :notifications
  end
end
