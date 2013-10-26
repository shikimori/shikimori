class AddPageViewsIndexToManga < ActiveRecord::Migration
  def self.up
    add_index :mangas, :page_views_counter
  end

  def self.down
    remove_index :mangas, :page_views_counter
  end
end
