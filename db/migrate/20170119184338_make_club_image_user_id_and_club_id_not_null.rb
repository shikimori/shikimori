class MakeClubImageUserIdAndClubIdNotNull < ActiveRecord::Migration[5.2]
  def up
    change_column :club_images, :club_id, :integer, null: false
    change_column :club_images, :user_id, :integer, null: false
  end

  def down
    change_column :club_images, :club_id, :integer, null: true
    change_column :club_images, :user_id, :integer, null: true
  end
end
