class CreatePosters < ActiveRecord::Migration[6.1]
  def change
    create_table :posters do |t|
      t.references :anime, null: false, foreign_key: true, index: true, null: true
      t.references :manga, null: false, foreign_key: true, index: true, null: true
      t.references :character, null: false, foreign_key: true, index: true, null: true
      t.references :person, null: false, foreign_key: true, index: true, null: true
      t.jsonb :image_data, null: false

      t.timestamps
    end
  end
end
