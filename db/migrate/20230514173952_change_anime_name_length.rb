class ChangeAnimeNameLength < ActiveRecord::Migration[6.1]
  def change
    change_column :animes, :name, :string, limit: 350
    change_column :mangas, :name, :string, limit: 350
  end
end
