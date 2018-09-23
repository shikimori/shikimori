class AddNotificationsSettingsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :notification_settings, :jsonb, null: false, default: {}
  end
end
