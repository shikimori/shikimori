class MakeFavouriteKindNotNullable < ActiveRecord::Migration[5.2]
  def change
    Favourite.where(kind: nil).update_all kind: ''
    change_column_default :favourites, :kind, ''
    change_column :favourites, :kind, :string, null: false, default: ''
  end
end
