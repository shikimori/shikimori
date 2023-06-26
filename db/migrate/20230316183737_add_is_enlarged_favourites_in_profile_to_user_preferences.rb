class AddIsEnlargedFavouritesInProfileToUserPreferences < ActiveRecord::Migration[6.1]
  def change
    add_column :user_preferences, :is_enlarged_favourites_in_profile, :boolean,
      null: false,
      default: false
  end
end
