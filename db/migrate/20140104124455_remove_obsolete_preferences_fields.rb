class RemoveObsoletePreferencesFields < ActiveRecord::Migration
  def up
    remove_column :user_preferences, :anime_genres
    remove_column :user_preferences, :anime_studios
    remove_column :user_preferences, :manga_genres
    remove_column :user_preferences, :manga_publishers
    remove_column :user_preferences, :genres_graph
  end

  def down
    add_column :user_preferences, :anime_genres, :boolean, default: true
    add_column :user_preferences, :anime_studios, :boolean, default: true
    add_column :user_preferences, :manga_genres, :boolean, default: true
    add_column :user_preferences, :manga_publishers, :boolean, default: true
    add_column :user_preferences, :genres_graph, :boolean, default: true
  end
end
