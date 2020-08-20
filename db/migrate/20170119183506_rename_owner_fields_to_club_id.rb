class RenameOwnerFieldsToClubId < ActiveRecord::Migration[5.2]
  def change
    remove_column :club_images, :owner_type, :srtring, default: 'Club'
    rename_column :club_images, :owner_id, :club_id
  end
end
