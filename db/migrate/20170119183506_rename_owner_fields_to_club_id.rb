class RenameOwnerFieldsToClubId < ActiveRecord::Migration
  def change
    remove_column :club_images, :owner_type, :srtring, default: 'Club'
    rename_column :club_images, :owner_id, :club_id
  end
end
