class RenameClubImagesUploaderToUser < ActiveRecord::Migration[5.2]
  def change
    rename_column :club_images, :uploader_id, :user_id
  end
end
