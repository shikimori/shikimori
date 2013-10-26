class AddFieldsToProfileSettings < ActiveRecord::Migration
  def self.up
    add_column :profile_settings, :anime_genres, :boolean, :default => true
    add_column :profile_settings, :anime_studios, :boolean, :default => true
    add_column :profile_settings, :manga_genres, :boolean, :default => true
    add_column :profile_settings, :manga_publishers, :boolean, :default => true

    add_column :profile_settings, :genres_graph, :boolean, :default => false
  end

  def self.down
    remove_column :profile_settings, :anime_genres
    remove_column :profile_settings, :anime_studios
    remove_column :profile_settings, :manga_genres
    remove_column :profile_settings, :manga_publishers

    remove_column :profile_settings, :genres_graph
  end
end
