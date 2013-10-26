class RemovePageViewsCounterFromMangas < ActiveRecord::Migration
  def up
    remove_index :mangas, :page_views_counter
    remove_column :mangas, :page_views_counter
  end
end
