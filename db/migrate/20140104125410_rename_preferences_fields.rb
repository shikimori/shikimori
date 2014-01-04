class RenamePreferencesFields < ActiveRecord::Migration
  def change
    rename_column :user_preferences, :anime, :anime_in_profile
    rename_column :user_preferences, :manga, :manga_in_profile
    rename_column :user_preferences, :clubs, :clubs_in_profile
    rename_column :user_preferences, :comments, :comments_in_profile
    rename_column :user_preferences, :statistics, :statistics_in_profile
    rename_column :user_preferences, :statistics_start, :statistics_start_on
  end
end
