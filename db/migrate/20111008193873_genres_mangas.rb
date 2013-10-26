class GenresMangas < ActiveRecord::Migration
  def self.up
    create_table :genres_mangas, :id => false, :force => true do |t|
      t.integer :manga_id
      t.integer :genre_id
    end
  end

  def self.down
    drop_table :genres_mangas
  end
end
