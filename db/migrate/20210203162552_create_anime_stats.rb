class CreateAnimeStats < ActiveRecord::Migration[5.2]
  def change
    create_table :anime_stats do |t|
      t.jsonb :scores_stats, default: {}, null: false
      t.jsonb :list_stats, default: {}, null: false
      t.references :entry, null: false, index: true, foreign_key: true

      t.timestamps
    end
  end
end
