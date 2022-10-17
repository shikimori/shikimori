class OptimizeAnimeStatHistoryV1 < ActiveRecord::Migration[6.1]
  def change
    add_column :anime_stat_histories, :anime_id, :bigint
    add_column :anime_stat_histories, :manga_id, :bigint

    add_foreign_key :anime_stat_histories, :animes
    add_foreign_key :anime_stat_histories, :mangas

    reversible do |dir|
      dir.up do
        execute %q[
          update anime_stat_histories
            set anime_id = entry_id
            where entry_type = 'Anime'
        ]
        execute %q[
          update anime_stat_histories
            set manga_id = entry_id
            where entry_type = 'Manga'
        ]
      end
      dir.down do
        execute %q[
          update anime_stat_histories
            set entry_id = anime_id, entry_type = 'Anime'
            where anime_id is not null
        ]
        execute %q[
          update anime_stat_histories
            set entry_id = manga_id, entry_type = 'Manga'
            where manga_id is not null
        ]
      end
    end

    remove_column :anime_stat_histories, :entry_id, :bigint
    remove_column :anime_stat_histories, :entry_type, :string
  end
end
