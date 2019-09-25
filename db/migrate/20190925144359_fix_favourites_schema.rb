class FixFavouritesSchema < ActiveRecord::Migration[5.2]
  def change
    change_column :favourites, :linked_id, :integer, null: false
    change_column :favourites, :linked_type, :string, null: false
    change_column :favourites, :user_id, :integer, null: false
    change_column :favourites, :created_at, :datetime, null: false
    change_column :favourites, :updated_at, :datetime, null: false
    change_column :favourites, :kind, :string, null: true
  end
end
