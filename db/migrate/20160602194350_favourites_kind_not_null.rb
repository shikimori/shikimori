class FavouritesKindNotNull < ActiveRecord::Migration
  def change
    while ids = duplicates and ids.any?
      Favourite.where(id: ids).destroy_all
    end
    Favourite.where(kind: nil).update_all kind: ''

    change_column :favourites, :kind, :string, limit: 255, null: false
  end

private

  def duplicates
    Favourite
      .group('linked_id, linked_type, user_id')
      .having('count(*) > 1')
      .select('max(id) as id')
      .map(&:id)
  end
end
