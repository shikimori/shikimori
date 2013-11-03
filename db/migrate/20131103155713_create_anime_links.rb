class CreateAnimeLinks < ActiveRecord::Migration
  def change
    create_table :anime_links do |t|
      t.references :anime
      t.string :service, null: false
      t.string :identifier, null: false
      t.timestamps
    end

    add_index :anime_links, [:anime_id, :service, :identifier], unique: true
  end
end
