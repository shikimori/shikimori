class RemoveNotificationsFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :notifications
  end
end
