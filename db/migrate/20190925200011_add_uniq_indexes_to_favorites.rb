class AddUniqIndexesToFavorites < ActiveRecord::Migration[5.2]
  def change
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
end
