class AddCounterCacheToEntries < ActiveRecord::Migration
  def self.up
    add_column :entries, :comment_threads_count, :integer, :default => 0
  end

  def self.down
    remove_column :entries, :comment_threads_count
  end
end
