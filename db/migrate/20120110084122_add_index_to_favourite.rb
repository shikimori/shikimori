class AddIndexToFavourite < ActiveRecord::Migration
  def self.up
    add_index :favourites, [:linked_type, :linked_id], :name => :i_linked
  end

  def self.down
    remove_index :favourites, name: :i_linked
  end
end
