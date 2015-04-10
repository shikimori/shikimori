class RenameProfilePrivacyToListPrivacyInUserPreferences < ActiveRecord::Migration
  def change
    rename_column :user_preferences, :profile_privacy, :list_privacy
  end
end
