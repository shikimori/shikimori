class AddIdToGenresMangas < ActiveRecord::Migration
  def change
    add_column :genres_mangas, :id, :primary_key
  end
end
