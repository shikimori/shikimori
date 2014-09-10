class CreateVersions < ActiveRecord::Migration
  def change
    create_table :versions do |t|
      t.string :item_type
      t.integer :item_id
      t.text :item_diff
      t.integer :user_id
      t.string :state
      t.datetime :created_at
    end
    add_index :versions, [:item_type, :item_id]
  end
end
