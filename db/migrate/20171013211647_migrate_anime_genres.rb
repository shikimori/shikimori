class MigrateAnimeGenres < ActiveRecord::Migration[5.1]
  def up
    ApplicationRecord.connection.execute <<-SQL
      update animes
        set genre_ids = t.genre_ids
      from (
        select
          anime_id,
          array_agg(genre_id) as genre_ids
        from animes_genres
        group by anime_id
      ) t
      where
        animes.id = t.anime_id
    SQL
  end
end
