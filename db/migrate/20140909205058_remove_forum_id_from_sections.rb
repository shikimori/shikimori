class RemoveForumIdFromSections < ActiveRecord::Migration
  def change
    remove_column :sections, :forum_id, :integer
  end
end
