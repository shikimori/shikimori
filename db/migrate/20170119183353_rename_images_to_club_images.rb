class RenameImagesToClubImages < ActiveRecord::Migration[5.2]
  def change
    rename_table :images, :club_images
  end
end
