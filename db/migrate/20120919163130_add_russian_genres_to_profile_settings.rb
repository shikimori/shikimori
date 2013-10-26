class AddRussianGenresToProfileSettings < ActiveRecord::Migration
  def self.up
    add_column :profile_settings, :russian_genres, :boolean, null: false, default: true
  end

  def self.down
    remove_column :profile_settings, :russian_genres
  end
end
