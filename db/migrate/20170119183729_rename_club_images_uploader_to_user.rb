class RenameClubImagesUploaderToUser < ActiveRecord::Migration
  def change
    rename_column :club_images, :uploader_id, :user_id
  end
end
