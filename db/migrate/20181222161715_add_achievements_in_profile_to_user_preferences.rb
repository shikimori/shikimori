class AddAchievementsInProfileToUserPreferences < ActiveRecord::Migration[5.2]
  def change
    add_column :user_preferences, :achievements_in_profile, :boolean, null: false, default: true
  end
end
