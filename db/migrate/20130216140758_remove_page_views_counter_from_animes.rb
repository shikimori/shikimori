class RemovePageViewsCounterFromAnimes < ActiveRecord::Migration
  def up
    remove_index :animes, :page_views_counter
    remove_column :animes, :page_views_counter
  end
end
