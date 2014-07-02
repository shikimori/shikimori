class RemoveNullableFromKindInFavourites < ActiveRecord::Migration
  def up
    change_column :favourites, :kind, :string, null: true
    Favourite.where(kind: '').update_all kind: nil
  end

  def down
    Favourite.where(kind: nil).update_all kind: ''
    change_column :favourites, :kind, :string, null: false
  end
end
