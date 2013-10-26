class RenameImagesToAnimeImages < ActiveRecord::Migration
  def self.up
    rename_table :images, :anime_images
  end

  def self.down
    rename_table :anime_images, :images
  end
end
