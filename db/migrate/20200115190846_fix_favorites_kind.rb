class FixFavoritesKind < ActiveRecord::Migration[5.2]
  def change
    Favourite.where(kind: '').update_all kind: Types::Favourite::Kind[:common]
  end
end
