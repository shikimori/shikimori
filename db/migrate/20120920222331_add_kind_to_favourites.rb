class AddKindToFavourites < ActiveRecord::Migration
  def self.up
    add_column :favourites, :kind, :string, null: false, default: ''
    remove_index :favourites, name: 'uniq_favourites'
    add_index :favourites, [:linked_id, :linked_type, :kind, :user_id], :name => 'uniq_favourites', :unique => true
  end

  def self.down
    remove_index :favourites, name: 'uniq_favourites'
    add_index :favourites, [:linked_id, :linked_type, :user_id], :name => 'uniq_favourites', :unique => true
    remove_column :favourites, :kind
  end
end
