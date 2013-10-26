class CreateGenres < ActiveRecord::Migration
  def self.up
    create_table :genres do |t|
      t.string :name

      t.timestamps
    end

    create_table :animes_genres, :id => false do |t|
      t.integer :anime_id
      t.integer :genre_id
    end
  end

  def self.down
    drop_table :genres
    drop_table :animes_genres
  end
end

