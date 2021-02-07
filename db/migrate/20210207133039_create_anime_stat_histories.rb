class CreateAnimeStatHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :anime_stat_histories do |t|
      t.jsonb :scores_stats, default: [], null: false
      t.jsonb :list_stats, default: [], null: false
      t.references :entry,
        polymorphic: true,
        null: false,
        index: { unique: true }

      t.date :created_on, null: false
    end

    add_index :anime_stat_histories, %i[entry_id entry_type created_on],
      unique: true,
      name: :index_anime_stat_histories_on_e_id_and_e_type_and_created_on
  end
end
