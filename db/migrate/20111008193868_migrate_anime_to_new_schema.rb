class MigrateAnimeToNewSchema < ActiveRecord::Migration
  def self.up
    rename_column :animes, :description_long, :description
    remove_column :animes, :description_short
    rename_column :animes, :atype, :kind
    rename_column :animes, :released, :released_at
    rename_column :animes, :aired, :aired_at
  end

  def self.down
    rename_column :animes, :description, :description_long
    add_column :animes, :description_short, :text
    rename_column :animes, :kind, :atype
    rename_column :animes, :released_at, :released
    rename_column :animes, :aired_at, :aired
  end
end
