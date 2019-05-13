class RemoveUnusedIndexes < ActiveRecord::Migration[5.2]
  def change
    remove_index :users, name: 'index_users_on_notification_settings'
    remove_index :users, name: 'index_users_on_remember_token'
  end
end
