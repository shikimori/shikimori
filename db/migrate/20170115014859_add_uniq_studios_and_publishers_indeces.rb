class AddUniqStudiosAndPublishersIndeces < ActiveRecord::Migration[5.2]
  def up
    10.times do
      Anime.connection.execute("
        delete from animes_studios where id in
        (
          select min(id)
            from animes_studios
            group by anime_id, studio_id
            having count(id) > 1
        )
      ")
      Anime.connection.execute("
        delete from mangas_publishers where id in
        (
          select min(id)
            from mangas_publishers
            group by manga_id, publisher_id
            having count(id) > 1
        )
      ")
    end
    add_index :animes_studios, [:anime_id, :studio_id], unique: true
    add_index :mangas_publishers, [:manga_id, :publisher_id], unique: true
  end

  def down
    remove_index :animes_studios, [:anime_id, :studio_id]
    remove_index :mangas_publishers, [:manga_id, :Publisher_id]
  end
end
