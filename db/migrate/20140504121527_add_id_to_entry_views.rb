class AddIdToEntryViews < ActiveRecord::Migration
  def change
    add_column :entry_views, :id, :primary_key
  end
end
