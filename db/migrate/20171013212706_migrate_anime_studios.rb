class MigrateAnimeStudios < ActiveRecord::Migration[5.1]
  def up
    ApplicationRecord.connection.execute <<-SQL
      update animes
        set studio_ids = t.studio_ids
      from (
        select
          anime_id,
          array_agg(studio_id) as studio_ids
        from animes_studios
        group by anime_id
      ) t
      where
        animes.id = t.anime_id
    SQL
  end
end
