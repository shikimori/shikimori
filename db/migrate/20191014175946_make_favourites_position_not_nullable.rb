class MakeFavouritesPositionNotNullable < ActiveRecord::Migration[5.2]
  def change
    User
      .where(id: Favourite.where(position: nil).distinct.pluck(:user_id))
      .find_each do |user|
        puts user.id
        user
          .favourites
          .group_by { |v| [v.linked_type, v.kind] }
          .values
          .each do |favorites|
            favorites.each_with_index do |v, index|
              v.update_column :position, index
            end
          end
      end

    change_column :favourites, :position, :integer, null: false
  end
end
