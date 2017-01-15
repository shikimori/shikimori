class AddIdToAnimesGenres < ActiveRecord::Migration
  def change
    add_column :animes_genres, :id, :primary_key
  end
end
