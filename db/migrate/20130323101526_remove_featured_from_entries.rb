class RemoveFeaturedFromEntries < ActiveRecord::Migration
  def up
    remove_column :entries, :featured
  end
end
