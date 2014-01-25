class AddDimensionsToUserImages < ActiveRecord::Migration
  def change
    add_column :user_images, :width, :integer
    add_column :user_images, :height, :integer
  end
end
