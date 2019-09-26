class AddUniqIndexesToFavorites < ActiveRecord::Migration[5.2]
  def change
    cleanup do
      Favourite.where('kind is null').group('user_id, linked_id, linked_type').having('count(*) > 1').select('max(id) as id, count(*) as count')
    end
    cleanup do
      Favourite.where("kind is not null").group('user_id, linked_id, linked_type, kind').having('count(*) > 1').select('max(id) as id, count(*) as count')
    end

    remove_index :favourites, name: 'uniq_favourites'

    add_index :favourites, %w[linked_id linked_type kind user_id],
      name: 'favorites_linked_id_linked_type_kind_user_id',
      where: 'kind is not null',
      unique: true

    add_index :favourites, %w[linked_id linked_type user_id],
      name: 'favorites_linked_id_linked_type_user_id',
      where: 'kind is null',
      unique: true
  end

private

  def cleanup
    while yield.any?
      Favourite.where(id: yield.map(&:id)).destroy_all
    end
  end
end
