class AddUniqAniemsAndMangasGenresIndeces < ActiveRecord::Migration[5.2]
  def up
    10.times do
      Anime.connection.execute("
        delete from animes_genres where id in
        (
          select min(id)
            from animes_genres
            group by anime_id, genre_id
            having count(id) > 1
        )
      ")
      Anime.connection.execute("
        delete from genres_mangas where id in
        (
          select min(id)
            from genres_mangas
            group by genre_id, manga_id
            having count(id) > 1
        )
      ")
    end
    add_index :animes_genres, [:anime_id, :genre_id], unique: true
    add_index :genres_mangas, [:genre_id, :manga_id], unique: true
  end

  def down
    remove_index :animes_genres, [:anime_id, :genre_id]
    remove_index :genres_mangas, [:genre_id, :manga_id]
  end
end
