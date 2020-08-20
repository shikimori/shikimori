class AddIdToAnimesGenres < ActiveRecord::Migration[5.2]
  def change
    add_column :animes_genres, :id, :primary_key
  end
end
