class RenameAnimeAndMangaDatesColumns < ActiveRecord::Migration
  def change
    rename_column :animes, :aired_at, :aired_on
    rename_column :animes, :released_at, :released_on
    rename_column :mangas, :aired_at, :aired_on
    rename_column :mangas, :released_at, :released_on
  end
end
