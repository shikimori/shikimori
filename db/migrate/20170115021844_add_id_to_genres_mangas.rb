class AddIdToGenresMangas < ActiveRecord::Migration[5.2]
  def change
    add_column :genres_mangas, :id, :primary_key
  end
end
