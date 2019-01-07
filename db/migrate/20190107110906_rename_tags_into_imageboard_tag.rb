class RenameTagsIntoImageboardTag < ActiveRecord::Migration[5.2]
  def change
    rename_column :animes, :tags, :imageboard_tag
    rename_column :mangas, :tags, :imageboard_tag
    rename_column :characters, :tags, :imageboard_tag
  end
end
