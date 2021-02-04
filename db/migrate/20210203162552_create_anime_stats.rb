class CreateAnimeStats < ActiveRecord::Migration[5.2]
  def change
    create_table :anime_stats do |t|
      t.jsonb :scores_stats, default: [], null: false
      t.jsonb :list_stats, default: [], null: false
      t.references :entry, polymorphic: true, null: false, index: true

      t.timestamps null: false
    end
  end
end
