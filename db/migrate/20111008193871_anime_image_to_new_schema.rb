class AnimeImageToNewSchema < ActiveRecord::Migration
  def self.up
    rename_table :anime_images, :attached_images
    rename_column :attached_images, :anime_id, :owner_id
    add_column :attached_images, :owner_type, :string
    rename_column :attached_images, :mal, :url

    ActiveRecord::Base.connection.execute("update attached_images set owner_type = 'Anime'")
  end

  def self.down
    rename_column :attached_images, :url, :mal
    remove_column :attached_images, :owner_type
    rename_column :attached_images, :owner_id, :anime_id
    rename_table :attached_images, :anime_images
  end
end
