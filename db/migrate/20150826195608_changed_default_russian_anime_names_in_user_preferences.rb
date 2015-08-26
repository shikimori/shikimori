class ChangedDefaultRussianAnimeNamesInUserPreferences < ActiveRecord::Migration
  def up
    change_column :user_preferences, :russian_names, :boolean, default: true
  end

  def down
    change_column :user_preferences, :russian_names, :boolean, default: false
  end
end
