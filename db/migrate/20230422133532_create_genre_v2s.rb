class CreateGenreV2s < ActiveRecord::Migration[6.1]
  def change
    create_table :genre_v2s do |t|
      t.string :name, null: false
      t.string :russian, null: false
      t.string :entry_type, null: false
      t.string :kind, null: false
      t.bigint :mal_id, null: false
      t.boolean :is_active, null: false, default: true
      t.boolean :is_censored, null: false, default: false
      t.integer :position, null: false, default: 99
      t.integer :seo, null: false, default: 99
      t.string :description, null: false, default: ''

      t.timestamps
    end
  end
end
