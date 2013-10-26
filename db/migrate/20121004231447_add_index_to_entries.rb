class AddIndexToEntries < ActiveRecord::Migration
  def self.up
    add_index :entries, [:in_forum, :type, :created_at]
  end

  def self.down
    remove_index :entries, [:in_forum, :type, :created_at]
  end
end
