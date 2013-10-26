class AddUserIdToCosplayGallery < ActiveRecord::Migration
  def self.up
    add_column :cosplay_galleries, :user_id, :integer
  end

  def self.down
    remove_column :cosplay_galleries, :user_id
  end
end
