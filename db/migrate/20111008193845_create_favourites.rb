class CreateFavourites < ActiveRecord::Migration
  def self.up
    create_table :favourites do |t|
      t.integer :linked_id
      t.string :linked_type
      t.integer :user_id

      t.timestamps
    end
    add_index :favourites, [:linked_id, :linked_type, :user_id], :name => 'uniq_favourites', :unique => true
  end

  def self.down
    drop_table :favourites
  end
end
