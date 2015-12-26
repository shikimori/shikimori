class RenameSectionsToForums < ActiveRecord::Migration
  def change
    rename_table :sections, :forums
    rename_column :entries, :section_id, :forum_id
  end
end
