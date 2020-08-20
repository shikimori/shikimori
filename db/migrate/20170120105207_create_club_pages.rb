class CreateClubPages < ActiveRecord::Migration[5.2]
  def change
    create_table :club_pages do |t|
      t.references :club, index: true, null: false
      t.integer :parent_id
      t.string :name, null: false
      t.text :text, null: false

      t.timestamps null: false
    end
  end
end
