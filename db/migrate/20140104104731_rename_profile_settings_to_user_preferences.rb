class RenameProfileSettingsToUserPreferences < ActiveRecord::Migration
  def change
    rename_table :profile_settings, :user_preferences
  end
end
