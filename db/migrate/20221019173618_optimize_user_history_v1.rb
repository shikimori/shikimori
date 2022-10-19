class OptimizeUserHistoryV1 < ActiveRecord::Migration[6.1]
  def change
    add_column :user_histories, :anime_id, :bigint
    add_column :user_histories, :manga_id, :bigint

    remove_index :user_histories, %w[target_type user_id id],
      name: :index_user_histories_on_target_type_and_user_id_and_id

    add_foreign_key :user_histories, :animes
    add_foreign_key :user_histories, :mangas

    reversible do |dir|
      dir.up do
        execute %q[
          update user_histories
            set anime_id = target_id
            where target_type = 'Anime'
        ]
        execute %q[
          update user_histories
            set manga_id = target_id
            where target_type != 'Anime'
        ]
      end
      dir.down do
        execute %q[
          update user_histories
            set target_id = anime_id, target_type = 'Anime'
            where anime_id is not null
        ]
        execute %q[
          update user_histories
            set target_id = manga_id, target_type = 'Manga'
            where manga_id is not null
        ]
      end
    end

    remove_column :user_histories, :target_id, :bigint
    remove_column :user_histories, :target_type, :string
  end
end
