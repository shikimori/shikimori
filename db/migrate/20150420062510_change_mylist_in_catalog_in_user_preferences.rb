class ChangeMylistInCatalogInUserPreferences < ActiveRecord::Migration
  def up
    change_column :user_preferences, :mylist_in_catalog, :boolean, default: true, null: false
  end

  def down
    change_column :user_preferences, :mylist_in_catalog, :boolean, default: false, null: false
  end
end
