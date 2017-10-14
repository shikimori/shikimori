class MigrateMangaPublishers < ActiveRecord::Migration[5.1]
  def up
    ApplicationRecord.connection.execute <<-SQL
      update mangas
        set publisher_ids = t.publisher_ids
      from (
        select
          manga_id,
          array_agg(publisher_id) as publisher_ids
        from mangas_publishers
        group by manga_id
      ) t
      where
        mangas.id = t.manga_id
    SQL
  end
end
