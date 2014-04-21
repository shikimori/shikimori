class AddVolumesInMangaToUserPreferences < ActiveRecord::Migration
  def change
    add_column :user_preferences, :volumes_in_manga, :boolean, default: false, null: false
  end
end
