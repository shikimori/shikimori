class RenameParentIdToParentPageIdInClubPages < ActiveRecord::Migration[5.2]
  def change
    rename_column :club_pages, :parent_id, :parent_page_id
  end
end
