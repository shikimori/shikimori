class AddIndexToTopicViews < ActiveRecord::Migration
  def self.up
    add_index :entry_views, :entry_id
  end

  def self.down
    remove_index :entry_views, :entry_id
  end
end
