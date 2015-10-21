class RemoveMylistInCatalogFromPreferences < ActiveRecord::Migration
  def change
    remove_column :user_preferences, :mylist_in_catalog, :boolean, default: true, null: false
  end
end
