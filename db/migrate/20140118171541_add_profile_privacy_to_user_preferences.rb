class AddProfilePrivacyToUserPreferences < ActiveRecord::Migration
  def change
    add_column :user_preferences, :profile_privacy, :string, default: 'public'
  end
end
