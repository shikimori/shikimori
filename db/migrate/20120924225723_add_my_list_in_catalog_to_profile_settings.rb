class AddMyListInCatalogToProfileSettings < ActiveRecord::Migration
  def self.up
    add_column :profile_settings, :mylist_in_catalog, :boolean, default: false, null: false
  end

  def self.down
    remove_column :profile_settings, :mylist_in_catalog
  end
end
