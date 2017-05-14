class RemoveUnneededIndexes < ActiveRecord::Migration[5.0]
  def up
    remove_index :anime_videos, name: "index_anime_videos_on_anime_id"
    remove_index :animes_genres, name: "index_animes_genres_on_anime_id"
    remove_index :animes_studios, name: "index_animes_studios_on_anime_id"
    remove_index :collection_links, name: "index_collection_links_on_collection_id"
    remove_index :mangas_publishers, name: "index_mangas_publishers_on_manga_id"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
