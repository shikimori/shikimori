class AddPositionToFavorites < ActiveRecord::Migration[5.2]
  def change
    add_column :favourites, :position, :integer
  end
end
