class RemoveLicensorColumn < ActiveRecord::Migration[5.2]
  def change
    remove_column :animes, :licensor
    remove_column :mangas, :licensor
  end
end
