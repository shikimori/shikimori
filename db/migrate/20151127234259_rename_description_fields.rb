class RenameDescriptionFields < ActiveRecord::Migration
  def change
    rename_column :animes, :description, :description_ru
    rename_column :animes, :description_mal, :description_en
    rename_column :mangas, :description, :description_ru
    rename_column :mangas, :description_mal, :description_en
    rename_column :characters, :description, :description_ru
    rename_column :characters, :description_mal, :description_en
  end
end
