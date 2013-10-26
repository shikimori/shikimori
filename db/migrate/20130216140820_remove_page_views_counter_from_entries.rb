class RemovePageViewsCounterFromEntries < ActiveRecord::Migration
  def up
    remove_column :entries, :page_views_counter
  end
end
