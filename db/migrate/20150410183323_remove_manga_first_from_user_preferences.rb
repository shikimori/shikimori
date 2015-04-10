class RemoveMangaFirstFromUserPreferences < ActiveRecord::Migration
  def change
    remove_column :user_preferences, :manga_first, :boolean, default: false
    remove_column :user_preferences, :clubs_in_profile, :boolean, default: true
    remove_column :user_preferences, :statistics_in_profile, :boolean, default: true
  end
end
