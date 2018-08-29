class AddFavoritesInProfileToUserPreferences < ActiveRecord::Migration[5.2]
  def change
    add_column :user_preferences, :favorites_in_profile, :integer, null: false, default: 8
  end
end
