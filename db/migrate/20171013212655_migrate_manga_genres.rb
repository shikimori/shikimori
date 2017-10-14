class MigrateMangaGenres < ActiveRecord::Migration[5.1]
  def up
    ApplicationRecord.connection.execute <<-SQL
      update mangas
        set genre_ids = t.genre_ids
      from (
        select
          manga_id,
          array_agg(genre_id) as genre_ids
        from genres_mangas
        group by manga_id
      ) t
      where
        mangas.id = t.manga_id
    SQL
  end
end
