class AddIsHashedToUserImages < ActiveRecord::Migration[7.0]
  def change
    add_column :user_images, :is_hashed, :boolean, null: false, default: false
    change_column_default :user_images, :is_hashed, from: false, to: true

    reversible do |dir|
      dir.up do
        UserImage.where('id >= ?', UserImage::SECOND_FIX_IMAGE_ID).update_all is_hashed: true
      end
    end
  end
end
