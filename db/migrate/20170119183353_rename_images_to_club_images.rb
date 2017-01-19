class RenameImagesToClubImages < ActiveRecord::Migration
  def change
    rename_table :images, :club_images
  end
end
