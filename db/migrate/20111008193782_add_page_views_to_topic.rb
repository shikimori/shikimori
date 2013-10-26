class AddPageViewsToTopic < ActiveRecord::Migration
  def self.up
    add_column :topics, :page_views_counter, :integer, :default => 0
    add_index :topics, :page_views_counter
  end

  def self.down
    remove_index :topics, :page_views_counter
    remove_column :topics, :page_views_counter
  end
end
