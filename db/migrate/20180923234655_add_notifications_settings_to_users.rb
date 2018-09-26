class AddNotificationsSettingsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :notification_settings, :text, null: false, default: [], array: true
    add_index :users, :notification_settings
  end
end
