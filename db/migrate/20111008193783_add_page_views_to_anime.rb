class AddPageViewsToAnime < ActiveRecord::Migration
  def self.up
    add_column :animes, :page_views_counter, :integer, :default => 0
    add_index :animes, :page_views_counter
  end

  def self.down
    remove_index :animes, :page_views_counter
    remove_column :animes, :page_views_counter
  end
end
