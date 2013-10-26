class AddIndexToContestLinks < ActiveRecord::Migration
  def self.up
    add_index :contest_links, [:linked_id, :linked_type, :contest_id]
  end

  def self.down
    remove_index :contest_links, [:linked_id, :linked_type, :contest_id]
  end
end
