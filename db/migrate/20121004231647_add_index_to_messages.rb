class AddIndexToMessages < ActiveRecord::Migration
  def self.up
    add_index :messages, [:linked_type, :linked_id]
  end

  def self.down
    remove_index :messages, [:linked_type, :linked_id]
  end
end
