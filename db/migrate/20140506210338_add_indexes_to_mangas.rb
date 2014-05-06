class AddIndexesToMangas < ActiveRecord::Migration
  def change
    add_index :mangas, :score
    add_index :mangas, :name
    add_index :mangas, :russian
  end
end
