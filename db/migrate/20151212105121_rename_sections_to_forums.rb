class RenameSectionsToForums < ActiveRecord::Migration
  def change
    rename_table :sections, :forums
    rename_column :entries, :forum_id, :forum_id
  end
end
